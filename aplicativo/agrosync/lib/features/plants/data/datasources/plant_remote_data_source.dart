import 'package:agrosync/features/plants/data/models/plant_model.dart';

abstract class PlantRemoteDataSource {
  Future<List<PlantModel>> getAllPlants();
  Future<void> addPlant(PlantModel plant);
  Future<void> updatePlant(PlantModel plant);
  Future<void> deletePlant(String id);
}