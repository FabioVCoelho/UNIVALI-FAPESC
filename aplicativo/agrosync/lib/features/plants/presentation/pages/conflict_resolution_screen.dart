import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConflictResolutionScreen extends StatelessWidget {
  final bool isAdmin;

  const ConflictResolutionScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conflict Resolution')),
        body: const Center(child: Text('Access denied. Admins only.')),
      );
    }

    final conflictsRef =
        FirebaseFirestore.instance.collection('plant_conflicts');

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Conflicts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: conflictsRef
            .orderBy('conflictTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No conflicts'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final plantId = data['plantId'] as String? ?? doc.id;
              final conflicting =
                  Map<String, dynamic>.from(data['conflictingData'] ?? {});
              final server =
                  Map<String, dynamic>.from(data['serverData'] ?? {});
              final userId = data['userId'] as String? ?? 'unknown';

              final diffs = _diffKeys(conflicting, server);

              return ExpansionTile(
                title: Text('Plant $plantId'),
                subtitle: Text(
                    'Submitted by: $userId  •  Differences: ${diffs.length}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _versionCard('User Version', conflicting,
                                diffs, Colors.orange.shade50)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _versionCard('Server Version', server, diffs,
                                Colors.green.shade50)),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          // Accept server version: just delete conflict doc
                          await conflictsRef.doc(doc.id).delete();
                        },
                        child: const Text('Accept Server Version'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Accept user's version: write to plants and delete conflict doc
                          final plantRef = FirebaseFirestore.instance
                              .collection('plants')
                              .doc(plantId);
                          final writeData =
                              Map<String, dynamic>.from(conflicting);
                          // preserve updatedBy as the conflicting user
                          if (!writeData.containsKey('updatedBy')) {
                            writeData['updatedBy'] = userId;
                          }
                          writeData['lastUpdated'] =
                              FieldValue.serverTimestamp();
                          await plantRef.set(writeData);
                          await conflictsRef.doc(doc.id).delete();
                        },
                        child: const Text("Accept User's Version"),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<String> _diffKeys(Map<String, dynamic> a, Map<String, dynamic> b) {
    final keys = {...a.keys, ...b.keys};
    final diffs = <String>[];
    for (final k in keys) {
      final va = a[k];
      final vb = b[k];
      if (!_valuesEqual(va, vb)) diffs.add(k);
    }
    return diffs;
  }

  bool _valuesEqual(dynamic a, dynamic b) {
    if (a is num && b is num) return a.toDouble() == b.toDouble();
    return a == b;
  }

  Widget _versionCard(
      String title, Map<String, dynamic> data, List<String> diffs, Color bg) {
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...data.entries.map((e) {
              final isDiff = diffs.contains(e.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDiff ? Colors.red : null),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: isDiff ? Colors.red : null),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
