import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlants extends PlantEvent {}

class AddPlant extends PlantEvent {
  final PlantEntity plant;

  const AddPlant(this.plant);

  @override
  List<Object?> get props => [plant];
}

/// New event: carry raw user inputs; bloc will fetch location and create the model
class AddPlantRequested extends PlantEvent {
  final String date;
  final String pasture;
  final String species;
  final int quantity;
  final String soilCondition;
  final String culture;
  final double freshWeight;
  final double dryWeight;

  const AddPlantRequested({
    required this.date,
    required this.pasture,
    required this.species,
    required this.quantity,
    required this.soilCondition,
    required this.culture,
    required this.freshWeight,
    required this.dryWeight,
  });

  @override
  List<Object?> get props => [
        date,
        pasture,
        species,
        quantity,
        soilCondition,
        culture,
        freshWeight,
        dryWeight,
      ];
}

class UpdatePlant extends PlantEvent {
  final PlantEntity plant;

  const UpdatePlant(this.plant);

  @override
  List<Object?> get props => [plant];
}

class DeletePlant extends PlantEvent {
  final String id;

  const DeletePlant(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterPlants extends PlantEvent {
  final String? date;
  final String? pasture;
  final String? species;
  final String? soilCondition;
  final String? culture;

  const FilterPlants({
    this.date,
    this.pasture,
    this.species,
    this.soilCondition,
    this.culture,
  });

  @override
  List<Object?> get props => [date, pasture, species, soilCondition, culture];
}

class SyncWithFirestore extends PlantEvent {}