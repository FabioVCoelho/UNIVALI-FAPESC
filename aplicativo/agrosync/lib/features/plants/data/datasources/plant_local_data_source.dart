import 'package:agrosync/features/plants/data/models/plant_model.dart';

abstract class PlantLocalDataSource {
  Future<List<PlantModel>> getAllPlants();

  Future<List<PlantModel>> getNeedsSyncPlants();

  Future<PlantModel?> getPlantById(String id);

  Future<void> cachePlant(PlantModel plant);

  Future<void> updatePlant(PlantModel plant);

  Future<void> setNeedsSync(String id, bool needsSync);

  Future<void> setStatus(String id, String? status);

  Future<void> deletePlant(String id);

  // Pending deletions queue stored locally
  Future<List<String>> getPendingDeletions();

  Future<void> addPendingDeletion(String id);

  Future<void> clearPendingDeletion(String id);
}
