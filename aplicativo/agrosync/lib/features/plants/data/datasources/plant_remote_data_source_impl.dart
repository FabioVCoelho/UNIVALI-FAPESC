import 'package:agrosync/features/plants/data/datasources/plant_remote_data_source.dart';
import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConflictDetectedException implements Exception {
  final String message;

  ConflictDetectedException([this.message = 'Conflict detected']);

  @override
  String toString() => message;
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  final FirebaseFirestore firestore;

  PlantRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _plantsCol =>
      firestore.collection('plants');

  CollectionReference<Map<String, dynamic>> get _conflictsCol =>
      firestore.collection('plant_conflicts');

  @override
  Future<List<PlantModel>> getAllPlants() async {
    final snapshot = await _plantsCol.get();
    return snapshot.docs
        .map((doc) => PlantModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addPlant(PlantModel plant) async {
    await _addOrUpdateWithConflict(plant, isCreate: true);
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    await _addOrUpdateWithConflict(plant, isCreate: false);
  }

  Future<void> _addOrUpdateWithConflict(PlantModel plant,
      {required bool isCreate}) async {
    final docRef = _plantsCol.doc(plant.id);
    final serverSnap = await docRef.get();

    if (!serverSnap.exists) {
      // No conflict possible if creating a new doc
      final createData = plant.toFirestore();
      // Set creation metadata
      createData['createdBy'] = plant.createdBy ?? plant.updatedBy;
      createData['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(createData);
      // Write history entry
      await docRef.collection('history').add({
        'action': 'create',
        'userId': plant.createdBy ?? plant.updatedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'data': plant.toFirestore(includeServerTimestamp: false),
      });
      return;
    }

    // Server document exists; check conflict
    final serverData = serverSnap.data()!;
    final serverLast = serverData['lastUpdated'];
    final localLast = plant.lastUpdated;

    if (serverLast is Timestamp && localLast is Timestamp) {
      if (serverLast.compareTo(localLast) > 0) {
        // Server is newer; check if there are actual domain differences
        final localData = plant.toFirestore(includeServerTimestamp: false, includeAuditFields: false);
        bool _numEq(dynamic a, dynamic b) {
          if (a is num && b is num) return a.toDouble() == b.toDouble();
          return a == b;
        }
        const domainKeys = [
          'date', 'pasture', 'species', 'quantity', 'condicaoSolo', 'culture',
          'fresh_weight', 'dry_weight', 'latitude', 'longitude'
        ];
        final same = domainKeys.every((k) => _numEq(localData[k], serverData[k]));
        if (!same) {
          // Conflict: server is newer and values differ
          await _conflictsCol.doc(plant.id).set({
            'plantId': plant.id,
            'conflictingData': plant.toFirestore(includeServerTimestamp: false, includeAuditFields: true),
            'serverData': serverData,
            'userId': plant.updatedBy,
            'conflictTimestamp': FieldValue.serverTimestamp(),
          });
          throw ConflictDetectedException();
        }
        // No meaningful differences: treat as no conflict; allow repository to proceed
      }
    } else if (serverLast is Timestamp && localLast == null) {
      // Local has no knowledge of server timestamp; check if actual values differ
      final localData = plant.toFirestore(includeServerTimestamp: false, includeAuditFields: false);
      bool _numEq(dynamic a, dynamic b) {
        if (a is num && b is num) return a.toDouble() == b.toDouble();
        return a == b;
      }
      const domainKeys = [
        'date', 'pasture', 'species', 'quantity', 'condicaoSolo', 'culture',
        'fresh_weight', 'dry_weight', 'latitude', 'longitude'
      ];
      final same = domainKeys.every((k) => _numEq(localData[k], serverData[k]));
      if (!same) {
        await _conflictsCol.doc(plant.id).set({
          'plantId': plant.id,
          'conflictingData': plant.toFirestore(includeServerTimestamp: false, includeAuditFields: true),
          'serverData': serverData,
          'userId': plant.updatedBy,
          'conflictTimestamp': FieldValue.serverTimestamp(),
        });
        throw ConflictDetectedException();
      }
      // No differences: treat as no conflict; proceed without throwing
    }

    // No conflict: proceed to write, updating lastUpdated and updatedBy
    final beforeData = serverData;
    final afterData = plant.toFirestore();
    // Compute diff
    final changes = <String, dynamic>{};
    for (final key in afterData.keys) {
      final b = beforeData[key];
      final a = afterData[key];
      if (a is FieldValue) continue; // skip server timestamp placeholder
      if (b != a) {
        changes[key] = {'from': b, 'to': a};
      }
    }
    await docRef.set(afterData);
    // Append history entry
    await docRef.collection('history').add({
      'action': 'update',
      'userId': plant.updatedBy,
      'timestamp': FieldValue.serverTimestamp(),
      'changes': changes,
    });
  }

  @override
  Future<void> deletePlant(String id) async {
    final docRef = _plantsCol.doc(id);
    final snap = await docRef.get();
    final data = snap.data();
    // Write history before deleting
    await docRef.collection('history').add({
      'action': 'delete',
      'timestamp': FieldValue.serverTimestamp(),
      'data': data,
    });
    await docRef.delete();
  }
}
