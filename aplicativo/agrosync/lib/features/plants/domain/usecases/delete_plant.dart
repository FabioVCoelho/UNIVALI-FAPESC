import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';

class DeletePlant {
  final PlantRepository repository;

  DeletePlant(this.repository);

  Future<void> call(String id) async {
    await repository.deletePlant(id);
  }
}