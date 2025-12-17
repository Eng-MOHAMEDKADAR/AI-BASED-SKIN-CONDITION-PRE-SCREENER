import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class ResultCard extends StatelessWidget {
  final ScanResult scan;

  const ResultCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scan.disease,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // ✅ Use diseaseConfidence instead of confidence
            Text(
              "Confidence: ${(scan.diseaseConfidence * 100).toStringAsFixed(1)}%",
            ),

            const SizedBox(height: 12),
            Text(
              "Organic Solution:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green[800],
              ),
            ),
            Text(scan.remedies.organicSolution),
            const SizedBox(height: 8),
            Text(
              "Chemical Solution:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red[800],
              ),
            ),
            Text(scan.remedies.chemicalSolution),
          ],
        ),
      ),
    );
  }
}
