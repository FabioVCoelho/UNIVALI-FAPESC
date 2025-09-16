import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantModel extends PlantEntity {
  final Timestamp? lastUpdated; // Firestore server timestamp (last modification)
  final String? updatedBy; // UID of the user who last updated
  final Timestamp? createdAt; // Firestore server timestamp (creation)
  final String? createdBy; // UID of the user who created
  final bool needsSync; // local-only flag for offline changes
  final String? status; // e.g., 'sync_conflict'

  const PlantModel({
    required String id,
    required String date,
    required String pasture,
    required String species,
    required int quantity,
    required String soilCondition,
    required String culture,
    required double freshWeight,
    required double dryWeight,
    double? latitude,
    double? longitude,
    this.lastUpdated,
    this.updatedBy,
    this.createdAt,
    this.createdBy,
    this.needsSync = false,
    this.status,
  }) : super(
          id: id,
          date: date,
          pasture: pasture,
          species: species,
          quantity: quantity,
          soilCondition: soilCondition,
          culture: culture,
          freshWeight: freshWeight,
          dryWeight: dryWeight,
          latitude: latitude,
          longitude: longitude,
        );

  PlantModel copyWith({
    String? id,
    String? date,
    String? pasture,
    String? species,
    int? quantity,
    String? soilCondition,
    String? culture,
    double? freshWeight,
    double? dryWeight,
    double? latitude,
    double? longitude,
    Timestamp? lastUpdated,
    String? updatedBy,
    Timestamp? createdAt,
    String? createdBy,
    bool? needsSync,
    String? status,
  }) {
    return PlantModel(
      id: id ?? this.id,
      date: date ?? this.date,
      pasture: pasture ?? this.pasture,
      species: species ?? this.species,
      quantity: quantity ?? this.quantity,
      soilCondition: soilCondition ?? this.soilCondition,
      culture: culture ?? this.culture,
      freshWeight: freshWeight ?? this.freshWeight,
      dryWeight: dryWeight ?? this.dryWeight,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      needsSync: needsSync ?? this.needsSync,
      status: status ?? this.status,
    );
  }

  factory PlantModel.fromHive(Map<String, dynamic> hiveData) {
    final luMillis = hiveData["lastUpdated"] as int?;
    final caMillis = hiveData["createdAt"] as int?;
    return PlantModel(
      id: hiveData["ID"],
      date: hiveData["Data"],
      pasture: hiveData["Pasto"],
      species: hiveData["Espécie"],
      quantity: hiveData["Quantidade"],
      soilCondition: hiveData["Condição do Solo"] ?? hiveData["Condição da Área"] ?? "",
      culture: hiveData["Cultura"],
      freshWeight: (hiveData["Peso Verde"] is int)
          ? (hiveData["Peso Verde"] as int).toDouble()
          : hiveData["Peso Verde"] ?? 0.0,
      dryWeight: (hiveData["Peso Seco"] is int)
          ? (hiveData["Peso Seco"] as int).toDouble()
          : hiveData["Peso Seco"] ?? 0.0,
      latitude: hiveData["latitude"],
      longitude: hiveData["longitude"],
      lastUpdated: luMillis != null ? Timestamp.fromMillisecondsSinceEpoch(luMillis) : null,
      updatedBy: hiveData["updatedBy"],
      createdAt: caMillis != null ? Timestamp.fromMillisecondsSinceEpoch(caMillis) : null,
      createdBy: hiveData["createdBy"],
      needsSync: hiveData["needsSync"] ?? false,
      status: hiveData["status"],
    );
  }

  factory PlantModel.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    final ts = firestoreData["lastUpdated"];
    final ca = firestoreData["createdAt"];
    return PlantModel(
      id: id,
      date: firestoreData["date"] ?? "",
      pasture: firestoreData["pasture"] ?? "",
      species: firestoreData["species"] ?? "",
      quantity: firestoreData["quantity"] ?? 0,
      soilCondition: firestoreData["condicaoSolo"] ?? "",
      culture: firestoreData["culture"] ?? "",
      freshWeight: (firestoreData["fresh_weight"] is int)
          ? (firestoreData["fresh_weight"] as int).toDouble()
          : firestoreData["fresh_weight"] ?? 0.0,
      dryWeight: (firestoreData["dry_weight"] is int)
          ? (firestoreData["dry_weight"] as int).toDouble()
          : firestoreData["dry_weight"] ?? 0.0,
      latitude: firestoreData["latitude"],
      longitude: firestoreData["longitude"],
      lastUpdated: ts is Timestamp ? ts : null,
      updatedBy: firestoreData["updatedBy"],
      createdAt: ca is Timestamp ? ca : null,
      createdBy: firestoreData["createdBy"],
      needsSync: false,
      status: null,
    );
  }

  Map<String, dynamic> toHive() {
    return {
      "ID": id,
      "Data": date,
      "Pasto": pasture,
      "Espécie": species,
      "Quantidade": quantity,
      "Condição do Solo": soilCondition,
      "Cultura": culture,
      "Peso Verde": freshWeight,
      "Peso Seco": dryWeight,
      "latitude": latitude,
      "longitude": longitude,
      "lastUpdated": lastUpdated?.millisecondsSinceEpoch,
      "updatedBy": updatedBy,
      "createdAt": createdAt?.millisecondsSinceEpoch,
      "createdBy": createdBy,
      "needsSync": needsSync,
      "status": status,
    };
  }

  Map<String, dynamic> toFirestore({bool includeServerTimestamp = true, bool includeAuditFields = true}) {
    final data = {
      "date": date,
      "pasture": pasture,
      "species": species,
      "quantity": quantity,
      "condicaoSolo": soilCondition,
      "culture": culture,
      "fresh_weight": freshWeight,
      "dry_weight": dryWeight,
      "latitude": latitude,
      "longitude": longitude,
      "updatedBy": updatedBy,
    };
    if (includeAuditFields) {
      // Pass through creation metadata when available (read-friendly; server will ignore on update)
      if (createdBy != null) data["createdBy"] = createdBy;
      if (createdAt != null) data["createdAt"] = createdAt;
    }
    if (includeServerTimestamp) {
      data["lastUpdated"] = FieldValue.serverTimestamp();
    } else if (lastUpdated != null) {
      data["lastUpdated"] = lastUpdated;
    }
    return data;
  }
}