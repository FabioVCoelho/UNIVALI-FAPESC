import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/domain/usecases/add_plant.dart'
    as usecase;
import 'package:agrosync/features/plants/domain/usecases/delete_plant.dart'
    as usecase;
import 'package:agrosync/features/plants/domain/usecases/get_all_plants.dart'
    as usecase;
import 'package:agrosync/features/plants/domain/usecases/sync_with_firestore.dart'
    as usecase;
import 'package:agrosync/features/plants/domain/usecases/update_plant.dart'
    as usecase;
import 'package:agrosync/features/plants/presentation/bloc/plant_event.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  // Persist last-applied filter criteria to avoid races when data reloads
  String? _lastDate;
  String? _lastPasture;
  String? _lastSpecies;
  String? _lastSoilCondition;
  String? _lastCulture;
  final usecase.GetAllPlants getAllPlants;
  final usecase.AddPlant addPlant;
  final usecase.UpdatePlant updatePlant;
  final usecase.DeletePlant deletePlant;
  final usecase.SyncWithFirestore syncWithFirestore;

  PlantBloc({
    required this.getAllPlants,
    required this.addPlant,
    required this.updatePlant,
    required this.deletePlant,
    required this.syncWithFirestore,
  }) : super(PlantInitial()) {
    on<LoadPlants>(_onLoadPlants);
    on<AddPlant>(_onAddPlant);
    on<AddPlantRequested>(_onAddPlantRequested);
    on<UpdatePlant>(_onUpdatePlant);
    on<DeletePlant>(_onDeletePlant);
    on<FilterPlants>(_onFilterPlants);
    on<SyncWithFirestore>(_onSyncWithFirestore);
  }

  // Build a PlantLoaded applying last-known filters
  PlantLoaded _buildLoadedWithFilters(List<PlantEntity> plants) {
    final filtered = _applyCurrentFilter(plants);
    return PlantLoaded(plants: plants, filteredPlants: filtered);
  }

  List<PlantEntity> _applyCurrentFilter(List<PlantEntity> plants) {
    bool matches(PlantEntity plant) {
      bool containsIgnoreCase(String hay, String needle) => hay.toLowerCase().contains(needle.toLowerCase());
      final byDate = (_lastDate == null || _lastDate!.isEmpty) || containsIgnoreCase(plant.date, _lastDate!);
      final byPasture = (_lastPasture == null || _lastPasture!.isEmpty) || containsIgnoreCase(plant.pasture, _lastPasture!);
      final bySpecies = (_lastSpecies == null || _lastSpecies!.isEmpty) || containsIgnoreCase(plant.species, _lastSpecies!);
      final byCond = (_lastSoilCondition == null || _lastSoilCondition!.isEmpty) || containsIgnoreCase(plant.soilCondition, _lastSoilCondition!);
      final byCulture = (_lastCulture == null || _lastCulture!.isEmpty) || containsIgnoreCase(plant.culture, _lastCulture!);
      return byDate && byPasture && bySpecies && byCond && byCulture;
    }
    return plants.where(matches).toList();
  }

  Future<void> _onLoadPlants(LoadPlants event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      final plants = await getAllPlants();
      emit(_buildLoadedWithFilters(plants));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePlant(
      UpdatePlant event, Emitter<PlantState> emit) async {
    if (state is PlantLoaded) {
      try {
        await updatePlant(event.plant);
        final plants = await getAllPlants();
        emit(_buildLoadedWithFilters(plants));
      } catch (e) {
        emit(PlantError(message: e.toString()));
      }
    }
  }

  Future<void> _onDeletePlant(
      DeletePlant event, Emitter<PlantState> emit) async {
    if (state is PlantLoaded) {
      try {
        await deletePlant(event.id);
        final plants = await getAllPlants();
        emit(_buildLoadedWithFilters(plants));
      } catch (e) {
        emit(PlantError(message: e.toString()));
      }
    }
  }

  void _onFilterPlants(FilterPlants event, Emitter<PlantState> emit) {
    if (state is PlantLoaded) {
      // Persist last criteria
      _lastDate = event.date;
      _lastPasture = event.pasture;
      _lastSpecies = event.species;
      _lastSoilCondition = event.soilCondition;
      _lastCulture = event.culture;

      final currentState = state as PlantLoaded;
      final filteredPlants = _applyCurrentFilter(currentState.plants);
      emit(currentState.copyWith(filteredPlants: filteredPlants));
    }
  }

  Future<void> _onSyncWithFirestore(
      SyncWithFirestore event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      await syncWithFirestore();
      final plants = await getAllPlants();
      emit(_buildLoadedWithFilters(plants));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }

  Future<void> _onAddPlant(AddPlant event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      await addPlant(event.plant);
      final plants = await getAllPlants();
      emit(_buildLoadedWithFilters(plants));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }

  Future<void> _onAddPlantRequested(
      AddPlantRequested event, Emitter<PlantState> emit) async {
    // Emit loading immediately so UI can reflect busy state
    emit(PlantLoading());

    double? latitude;
    double? longitude;

    // Try to get location, but do not fail if unavailable or permissions denied
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition();
          latitude = pos.latitude;
          longitude = pos.longitude;
        }
      }
    } catch (_) {
      // ignore location errors; proceed without coordinates
    }

    final plant = PlantModel(
      id: const Uuid().v4(),
      date: event.date,
      pasture: event.pasture,
      species: event.species,
      quantity: event.quantity,
      soilCondition: event.soilCondition,
      culture: event.culture,
      freshWeight: event.freshWeight,
      dryWeight: event.dryWeight,
      latitude: latitude,
      longitude: longitude,
    );

    try {
      await addPlant(plant);
      final plants = await getAllPlants();
      emit(_buildLoadedWithFilters(plants));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }
}
