import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';

class SyncWithFirestore {
  final PlantRepository repository;

  SyncWithFirestore(this.repository);

  Future<void> call() async {
    await repository.syncWithFirestore();
  }
}