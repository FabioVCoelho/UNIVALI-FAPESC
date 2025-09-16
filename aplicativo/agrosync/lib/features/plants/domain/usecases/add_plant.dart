import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';

class AddPlant {
  final PlantRepository repository;

  AddPlant(this.repository);

  Future<void> call(PlantEntity plant) async {
    return await repository.addPlant(plant);
  }
}