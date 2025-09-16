import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDashboardSection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final GlobalKey? repaintKey;

  const CustomDashboardSection({
    super.key,
    required this.firestore,
    this.repaintKey,
  });

  Map<String, int> _countByPasture(List<Map<String, dynamic>> plants) {
    final Map<String, int> count = {};
    for (var plant in plants) {
      final pasture = plant['pasture'] ?? plant['Pasto'] ?? 'Desconhecido';
      count[pasture] = (count[pasture] ?? 0) + 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestore.collection('plants').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Erro ao carregar dados',
              style: TextStyle(color: Colors.white));
        }
        final docs = (snapshot.data as QuerySnapshot).docs;
        final plants = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        final data = _countByPasture(plants);
        final keys = data.keys.toList();

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF388E3C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plantas registradas por pasto',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: RepaintBoundary(
                  key: repaintKey,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: List.generate(keys.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data[keys[index]]!.toDouble(),
                              color: Colors.white,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < keys.length) {
                                return Text(
                                  'Pasto ${keys[idx]}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  textAlign: TextAlign.center,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
