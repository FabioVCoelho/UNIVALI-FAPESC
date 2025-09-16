import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/pdf_exporter.dart';

class PdfExporterImpl implements PdfExporter {
  const PdfExporterImpl();

  @override
  Future<void> exportPlantsReport({
    required BuildContext context,
    required List<Map<String, dynamic>> plants,
    GlobalKey? chartKey,
  }) async {
    Uint8List? chartImageBytes;
    // Try capture chart image if provided
    if (chartKey != null && chartKey.currentContext != null) {
      try {
        final boundary = chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        chartImageBytes = byteData?.buffer.asUint8List();
      } catch (_) {
        chartImageBytes = null;
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context _) => [
          pw.Text('Relatório Completo de Plantas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Data de geração: ${DateTime.now().toString().substring(0, 16)}'),
          pw.SizedBox(height: 16),
          if (chartImageBytes != null) ...[
            pw.Text('Gráfico: Plantas registradas por pasto', style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(chartImageBytes), height: 200),
            pw.SizedBox(height: 16),
          ],
          pw.Text('Lista completa de plantas:', style: const pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: const [
              'Espécie',
              'Pasto',
              'Cultura',
              'Data',
              'Condição',
              'Peso Fresco',
              'Peso Seco',
              'Quantidade',
              'Latitude',
              'Longitude',
            ],
            data: plants
                .map((p) => [
                      p['Espécie'],
                      p['Pasto'],
                      p['Cultura'],
                      p['Data'],
                      p['Condição'],
                      p['Peso Fresco'],
                      p['Peso Seco'],
                      p['Quantidade'],
                      p['Latitude'],
                      p['Longitude'],
                    ])
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    // Save into Downloads on Android-like path (same as previous behavior)
    final file = File('/storage/emulated/0/Download/relatorio_plantas.pdf');
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF salvo em: ${file.path}')),
      );
    }
  }

  @override
  Future<void> exportPlantsReportFromFirestore({
    required BuildContext context,
    FirebaseFirestore? firestore,
    GlobalKey? chartKey,
  }) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final snapshot = await fs.collection('plants').get();
    final List<Map<String, dynamic>> plants = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "Espécie": data["species"] ?? "",
        "Pasto": data["pasture"] ?? "",
        "Cultura": data["culture"] ?? "",
        "Data": data["date"] ?? "",
        "Condição": data["condicaoArea"] ?? data["condicao"] ?? data["condicaoSolo"] ?? "",
        "Peso Fresco": data["fresh_weight"]?.toString() ?? data["pesoVerde"]?.toString() ?? "",
        "Peso Seco": data["dry_weight"]?.toString() ?? data["pesoSeco"]?.toString() ?? "",
        "Quantidade": data["quantity"]?.toString() ?? data["quantidade"]?.toString() ?? "",
        "Latitude": data["latitude"]?.toString() ?? "",
        "Longitude": data["longitude"]?.toString() ?? "",
      };
    }).toList();

    await exportPlantsReport(context: context, plants: plants, chartKey: chartKey);
  }
}
