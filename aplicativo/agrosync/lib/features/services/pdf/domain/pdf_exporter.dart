import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstraction for exporting PDFs related to AgroSync reports.
abstract class PdfExporter {
  /// Exports a plants report PDF to the user's Downloads folder.
  ///
  /// - context: used for showing feedback (SnackBar) when appropriate.
  /// - plants: list of maps with human-readable keys expected by the report.
  /// - chartKey: optional RepaintBoundary GlobalKey to capture a chart image.
  Future<void> exportPlantsReport({
    required BuildContext context,
    required List<Map<String, dynamic>> plants,
    GlobalKey? chartKey,
  });

  /// Convenience API: fetches plants from Firestore and shapes the data
  /// internally before exporting the same report as above.
  Future<void> exportPlantsReportFromFirestore({
    required BuildContext context,
    FirebaseFirestore? firestore,
    GlobalKey? chartKey,
  });
}
