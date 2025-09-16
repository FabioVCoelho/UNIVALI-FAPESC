import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../datasources/plant_meta_cache_data_source.dart';
import '../datasources/plant_meta_local_data_source.dart';
import '../datasources/plant_meta_remote_data_source.dart';
import '../models/plant_meta.dart';

class PlantMetaRepository {
  final PlantMetaRemoteDataSource remote;
  final PlantMetaLocalDataSource localAsset;
  final PlantMetaCacheDataSource cache;
  final Connectivity connectivity;

  PlantMetaRepository({
    FirebaseFirestore? firestore,
    PlantMetaRemoteDataSource? remote,
    PlantMetaLocalDataSource? localAsset,
    PlantMetaCacheDataSource? cache,
    Connectivity? connectivity,
  })  : remote = remote ?? PlantMetaRemoteDataSource(firestore: firestore ?? FirebaseFirestore.instance),
        localAsset = localAsset ?? PlantMetaLocalDataSource(),
        cache = cache ?? PlantMetaCacheDataSource(),
        connectivity = connectivity ?? Connectivity();

  /// Load metadata with the following priority:
  /// 1) Remote server (Firestore Source.server)
  /// 2) Remote cache (Firestore Source.cache)
  /// 3) Device cache (Hive)
  /// 4) Local bundled asset
  Future<PlantMeta> load() async {
    // Try remote server first
    try {
      final meta = await remote.fetchFromServer();
      // persist to device cache
      await cache.save(meta);
      return meta;
    } catch (_) {}

    // Try remote cache from Firestore
    try {
      final meta = await remote.fetchFromRemoteCache();
      // persist to device cache (keep it aligned)
      await cache.save(meta);
      return meta;
    } catch (_) {}

    // Try device cache (Hive)
    try {
      final meta = await cache.load();
      return meta;
    } catch (_) {}

    // Finally fallback to local asset
    return await localAsset.load();
  }

  /// If internet is available, tries to refresh from server and update local device cache.
  Future<void> refreshInBackground() async {
    final status = await connectivity.checkConnectivity();
    final online = status.any((r) => r != ConnectivityResult.none);
    if (!online) return;
    try {
      final meta = await remote.fetchFromServer();
      await cache.save(meta);
    } catch (_) {
      // Ignore background refresh errors
    }
  }
}
