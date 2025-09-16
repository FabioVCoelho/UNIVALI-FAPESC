import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PlantState extends Equatable {
  const PlantState();

  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<PlantEntity> plants;
  final List<PlantEntity> filteredPlants;

  const PlantLoaded({
    required this.plants,
    required this.filteredPlants,
  });

  @override
  List<Object?> get props => [plants, filteredPlants];

  PlantLoaded copyWith({
    List<PlantEntity>? plants,
    List<PlantEntity>? filteredPlants,
  }) {
    return PlantLoaded(
      plants: plants ?? this.plants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
    );
  }
}

class PlantError extends PlantState {
  final String message;

  const PlantError({required this.message});

  @override
  List<Object?> get props => [message];
}