import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/plant_meta.dart';

class PlantMetaRemoteDataSource {
  // Firestore path where the metadata document is stored.
  // Adjust if your backend uses a different location.
  // Structure example: collection 'app_meta', doc 'plants'
  final String collectionPath;
  final String documentId;
  final FirebaseFirestore firestore;

  PlantMetaRemoteDataSource({
    required this.firestore,
    this.collectionPath = 'app_meta',
    this.documentId = 'plants',
  });

  Future<PlantMeta> fetchFromServer() async {
    final docRef = firestore.collection(collectionPath).doc(documentId);
    final snap = await docRef.get(const GetOptions(source: Source.server));
    if (!snap.exists) {
      throw StateError('Remote metadata document not found');
    }
    final data = snap.data();
    if (data == null) {
      throw StateError('Remote metadata is empty');
    }
    return PlantMeta.fromJson(Map<String, dynamic>.from(data));
  }

  Future<PlantMeta> fetchFromRemoteCache() async {
    final docRef = firestore.collection(collectionPath).doc(documentId);
    final snap = await docRef.get(const GetOptions(source: Source.cache));
    if (!snap.exists) {
      throw StateError('Cached remote metadata not found');
    }
    final data = snap.data();
    if (data == null) {
      throw StateError('Cached remote metadata is empty');
    }
    return PlantMeta.fromJson(Map<String, dynamic>.from(data));
  }
}
