import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/plant_meta.dart';

class PlantMetaCacheDataSource {
  static const String boxName = 'plant_meta_box';
  static const String keyCurrent = 'current_meta';

  Future<Box> _openBoxIfNeeded() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return Hive.openBox(boxName);
    }

  Future<void> save(PlantMeta meta) async {
    final box = await _openBoxIfNeeded();
    final jsonMap = <String, dynamic>{
      'species': meta.species,
      'cultures': meta.cultures,
      'conditions': meta.conditions,
    };
    await box.put(keyCurrent, json.encode(jsonMap));
  }

  Future<PlantMeta> load() async {
    final box = await _openBoxIfNeeded();
    final String? jsonStr = box.get(keyCurrent);
    if (jsonStr == null) {
      throw StateError('No cached meta');
    }
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return PlantMeta.fromJson(map);
  }
}
