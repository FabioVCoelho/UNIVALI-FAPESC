import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';

abstract class PlantRepository {
  Future<List<PlantEntity>> getAllPlants();
  Future<void> addPlant(PlantEntity plant);
  Future<void> updatePlant(PlantEntity plant);
  Future<void> deletePlant(String id);
  Future<void> syncWithFirestore();
}