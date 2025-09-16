import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';

class UpdatePlant {
  final PlantRepository repository;

  UpdatePlant(this.repository);

  Future<void> call(PlantEntity plant) async {
    await repository.updatePlant(plant);
  }
}