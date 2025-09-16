import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';

class GetAllPlants {
  final PlantRepository repository;

  GetAllPlants(this.repository);

  Future<List<PlantEntity>> call() async {
    return await repository.getAllPlants();
  }
}