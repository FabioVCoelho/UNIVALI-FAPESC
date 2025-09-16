import 'package:agrosync/features/plants/data/datasources/plant_local_data_source.dart';
import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:hive/hive.dart';

class PlantLocalDataSourceImpl implements PlantLocalDataSource {
  final Box plantBox;
  static const String _pendingDeletionsKey = '_pending_deletions';

  PlantLocalDataSourceImpl({required this.plantBox});

  String _historyKey(String id) => '_history:$id';

  Future<void> _appendHistory(String id, Map<String, dynamic> entry) async {
    final key = _historyKey(id);
    final current = plantBox.get(key);
    final list = (current is List) ? current.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];
    list.add(entry);
    await plantBox.put(key, list);
  }

  @override
  Future<List<PlantModel>> getAllPlants() async {
    final List<PlantModel> data = [];
    for (final key in plantBox.keys) {
      if (key is String && key.startsWith('_')) continue; // skip meta keys
      final item = plantBox.get(key);
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        // Ensure it's a Plant entry
        if (map.containsKey('ID')) {
          data.add(PlantModel.fromHive(map));
        }
      }
    }
    return data;
  }

  @override
  Future<List<PlantModel>> getNeedsSyncPlants() async {
    final all = await getAllPlants();
    return all.where((p) => p.needsSync).toList();
  }

  @override
  Future<PlantModel?> getPlantById(String id) async {
    final item = plantBox.get(id);
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      if (map.containsKey('ID')) {
        return PlantModel.fromHive(map);
      }
    }
    return null;
  }

  @override
  Future<void> cachePlant(PlantModel plant) async {
    await plantBox.put(plant.id, plant.toHive());
    await _appendHistory(plant.id, {
      'action': 'create',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'userId': plant.createdBy ?? plant.updatedBy,
      'data': plant.toHive(),
    });
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    // Compute a simple diff against existing
    Map<String, dynamic>? before;
    final existing = plantBox.get(plant.id);
    if (existing is Map) {
      before = Map<String, dynamic>.from(existing);
    }
    await plantBox.put(plant.id, plant.toHive());
    final after = plant.toHive();
    final changes = <String, dynamic>{};
    if (before != null) {
      for (final key in after.keys) {
        final b = before[key];
        final a = after[key];
        if (b != a) {
          changes[key] = {'from': b, 'to': a};
        }
      }
    }
    await _appendHistory(plant.id, {
      'action': 'update',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'userId': plant.updatedBy,
      'changes': changes,
    });
  }

  @override
  Future<void> setNeedsSync(String id, bool needsSync) async {
    final existing = plantBox.get(id);
    if (existing is Map) {
      final map = Map<String, dynamic>.from(existing);
      map['needsSync'] = needsSync;
      await plantBox.put(id, map);
    }
  }

  @override
  Future<void> setStatus(String id, String? status) async {
    final existing = plantBox.get(id);
    if (existing is Map) {
      final map = Map<String, dynamic>.from(existing);
      if (status == null) {
        map.remove('status');
      } else {
        map['status'] = status;
      }
      await plantBox.put(id, map);
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    // Persist a delete history event with snapshot before delete
    final existing = plantBox.get(id);
    Map<String, dynamic>? before;
    if (existing is Map) {
      before = Map<String, dynamic>.from(existing);
    }
    await _appendHistory(id, {
      'action': 'delete',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'userId': null,
      'data': before,
    });
    await plantBox.delete(id);
  }

  @override
  Future<List<String>> getPendingDeletions() async {
    final list = plantBox.get(_pendingDeletionsKey);
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<void> addPendingDeletion(String id) async {
    final current = await getPendingDeletions();
    if (!current.contains(id)) {
      current.add(id);
      await plantBox.put(_pendingDeletionsKey, current);
    }
  }

  @override
  Future<void> clearPendingDeletion(String id) async {
    final current = await getPendingDeletions();
    current.remove(id);
    await plantBox.put(_pendingDeletionsKey, current);
  }
}
