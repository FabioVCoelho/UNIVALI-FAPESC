import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/plant_meta.dart';

class PlantMetaLocalDataSource {
  static const String defaultAssetPath = 'assets/data/plants_metadata.json';

  final String assetPath;

  PlantMetaLocalDataSource({this.assetPath = defaultAssetPath});

  Future<PlantMeta> load() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
    return PlantMeta.fromJson(jsonMap);
  }
}