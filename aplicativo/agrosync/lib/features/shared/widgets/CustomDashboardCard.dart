import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDashboardCard extends StatelessWidget {
  final String title;
  final Future<int> futureValue;
  final Color? valueColor;
  final Color? titleColor;

  const CustomDashboardCard({
    super.key,
    required this.title,
    required this.futureValue,
    this.valueColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: futureValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        }
        if (snapshot.hasError) {
          return const Text('Erro', style: TextStyle(color: Colors.white));
        }
        return Column(
          children: [
            Text(
              snapshot.data.toString(),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: titleColor ?? Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
