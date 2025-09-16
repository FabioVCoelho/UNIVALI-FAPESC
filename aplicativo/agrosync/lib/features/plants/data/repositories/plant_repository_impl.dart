import 'dart:async';

import 'package:agrosync/features/plants/data/datasources/plant_local_data_source.dart';
import 'package:agrosync/features/plants/data/datasources/plant_remote_data_source.dart';
import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../datasources/plant_remote_data_source_impl.dart';

class PlantRepositoryImpl implements PlantRepository {
  Future<PlantModel?> _loadRemoteById(String id) async {
    try {
      final list = await remoteDataSource.getAllPlants();
      for (final p in list) {
        if (p.id == id) return p;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  final PlantLocalDataSource localDataSource;
  final PlantRemoteDataSource remoteDataSource;

  // Dependencies for online/offline and user context
  final Connectivity _connectivity;
  final FirebaseAuth _auth;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  PlantRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    Connectivity? connectivity,
    FirebaseAuth? auth,
  })  : _connectivity = connectivity ?? Connectivity(),
        _auth = auth ?? FirebaseAuth.instance {
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connSub?.cancel();
    _connSub = _connectivity.onConnectivityChanged.listen((results) async {
      final hasNet = results.any((r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi);
      if (hasNet) {
        await syncWithFirestore();
      }
    });
  }

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
  }

  String? _currentUid() => _auth.currentUser?.uid;

  @override
  Future<List<PlantEntity>> getAllPlants() async {
    return await localDataSource.getAllPlants();
  }

  @override
  Future<void> addPlant(PlantEntity plant) async {
    var model = plant as PlantModel;
    final uid = _currentUid();
    model = model.copyWith(updatedBy: uid, createdBy: uid);

    if (await _isOnline()) {
      // Online: write both
      final synced = model.copyWith(needsSync: false);
      await localDataSource.cachePlant(synced);
      try {
        await remoteDataSource.addPlant(synced);
        // After server write, load the server version to capture server timestamps (createdAt/lastUpdated)
        final remote = await _loadRemoteById(synced.id);
        if (remote != null) {
          await localDataSource.updatePlant(remote);
        }
      } on ConflictDetectedException {
        // Should not happen on create, but handle just in case
        await localDataSource.setStatus(model.id, 'sync_conflict');
      }
    } else {
      // Offline: local only, mark needsSync
      final offline = model.copyWith(needsSync: true);
      await localDataSource.cachePlant(offline);
    }
  }

  @override
  Future<void> updatePlant(PlantEntity plant) async {
    var model = plant as PlantModel;
    model = model.copyWith(updatedBy: _currentUid());

    if (await _isOnline()) {
      final synced = model.copyWith(needsSync: false);
      await localDataSource.updatePlant(synced);
      try {
        await remoteDataSource.updatePlant(synced);
        // Refresh local copy with server metadata (e.g., lastUpdated)
        final remote = await _loadRemoteById(synced.id);
        if (remote != null) {
          await localDataSource.updatePlant(remote);
        }
      } on ConflictDetectedException {
        await localDataSource.setStatus(model.id, 'sync_conflict');
      }
    } else {
      final offline = model.copyWith(needsSync: true);
      await localDataSource.updatePlant(offline);
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    if (await _isOnline()) {
      await localDataSource.deletePlant(id);
      await remoteDataSource.deletePlant(id);
    } else {
      await localDataSource.deletePlant(id);
      await localDataSource.addPendingDeletion(id);
    }
  }

  @override
  Future<void> syncWithFirestore() async {
    // Push local pending updates
    final pending = await localDataSource.getNeedsSyncPlants();
    for (final plant in pending) {
      final withUser = plant.copyWith(updatedBy: _currentUid());
      try {
        await remoteDataSource.updatePlant(withUser);
        // Pull the server version to capture server timestamps and authoritative values
        final remote = await _loadRemoteById(withUser.id);
        if (remote != null) {
          await localDataSource.updatePlant(remote);
        }
        // Mark as synced
        await localDataSource.setNeedsSync(plant.id, false);
        await localDataSource.setStatus(plant.id, null);
      } on ConflictDetectedException {
        // Mark conflict locally and do not overwrite remote
        await localDataSource.setStatus(plant.id, 'sync_conflict');
        // Keep needsSync = true to preserve local changes until conflict is resolved
      }
    }

    // Process pending deletions
    final deletions = await localDataSource.getPendingDeletions();
    for (final id in deletions) {
      await remoteDataSource.deletePlant(id);
      await localDataSource.clearPendingDeletion(id);
    }

    bool _numEq(dynamic a, dynamic b) {
      if (a is num && b is num) return a.toDouble() == b.toDouble();
      return a == b;
    }
    bool _modelsEqualIgnoringMeta(PlantModel a, PlantModel b) {
      return a.date == b.date &&
          a.pasture == b.pasture &&
          a.species == b.species &&
          a.quantity == b.quantity &&
          a.soilCondition == b.soilCondition &&
          a.culture == b.culture &&
          _numEq(a.freshWeight, b.freshWeight) &&
          _numEq(a.dryWeight, b.dryWeight) &&
          _numEq(a.latitude, b.latitude) &&
          _numEq(a.longitude, b.longitude);
    }

    // Pull remote latest into local cache (optional to ensure consistency)
    final remotePlants = await remoteDataSource.getAllPlants();
    for (var remote in remotePlants) {
      final local = await localDataSource.getPlantById(remote.id);
      if (local != null && local.status == 'sync_conflict') {
        // If local and remote match on domain fields, clear conflict and sync flags
        if (_modelsEqualIgnoringMeta(local, remote)) {
          await localDataSource.setStatus(remote.id, null);
          await localDataSource.setNeedsSync(remote.id, false);
          await localDataSource.cachePlant(remote);
          continue;
        }
      }
      final hasLocalPending = local?.needsSync == true || (local?.status == 'sync_conflict');
      // Only overwrite local if there are no pending local changes or conflicts
      if (!hasLocalPending) {
        await localDataSource.cachePlant(remote);
      }
    }
  }
}