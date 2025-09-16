import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/pdf_exporter_impl.dart';
import '../domain/pdf_exporter.dart';

/// Facade for PDF-related actions to be used by UI layers.
class PdfService {
  static final PdfExporter _exporter = const PdfExporterImpl();

  /// Delegates exporting of plants report.
  static Future<void> exportPlantsReport({
    required BuildContext context,
    required List<Map<String, dynamic>> plants,
    GlobalKey? chartKey,
  }) {
    return _exporter.exportPlantsReport(
      context: context,
      plants: plants,
      chartKey: chartKey,
    );
  }

  /// Convenience: fetch from Firestore and export.
  static Future<void> exportPlantsReportFromFirestore({
    required BuildContext context,
    FirebaseFirestore? firestore,
    GlobalKey? chartKey,
  }) {
    return _exporter.exportPlantsReportFromFirestore(
      context: context,
      firestore: firestore,
      chartKey: chartKey,
    );
  }
}
