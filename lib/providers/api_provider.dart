import 'dart:io';
import 'package:flutter/material.dart';

// Models
import '../models/scan_result.dart';
import '../models/remedy_model.dart';

// Services
import '../services/api_service.dart';

class ApiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;

  Future<ScanResult> detectDisease(File image) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.detectDisease(image);

      // ✅ Safely extract from result
      final resultMap = result as Map<String, dynamic>? ?? {};
      final resultData = resultMap['result'] as Map<String, dynamic>? ?? {};

      // --- Check if it's a plant ---
      final isPlantData = resultData['is_plant'] as Map<String, dynamic>? ?? {};
      final isPlant = isPlantData['binary'] ?? false;
      final plantProb = (isPlantData['probability'] ?? 0.0).toDouble();

      // --- Disease section ---
      final diseaseData = resultData['disease'] as Map<String, dynamic>? ?? {};
      final suggestions = diseaseData['suggestions'] as List? ?? [];

      String diseaseName = "Unknown";
      double diseaseConfidence = 0.0;

      if (isPlant && suggestions.isNotEmpty) {
        diseaseName = suggestions[0]['name'] ?? "Unknown Disease";
        diseaseConfidence =
            ((suggestions[0]['probability'] ?? 0.0) as num).toDouble();
      } else if (!isPlant) {
        diseaseName = "⚠️ This doesn’t look like a plant. Try again.";
        diseaseConfidence = plantProb;
      }

      // Remedies (hardcoded for now, but you can map diseases → remedies)
      final organic = isPlant
          ? "Use crop rotation, compost, and neem spray."
          : "No remedies available.";
      final chemical = isPlant
          ? "Apply recommended fertilizers or fungicides."
          : "No remedies available.";

      return ScanResult(
        crop: isPlant ? "Detected Crop" : "Not a Plant",
        cropConfidence: plantProb,
        disease: diseaseName,
        diseaseConfidence: diseaseConfidence,
        remedies: Remedy(
          organicSolution: organic,
          chemicalSolution: chemical,
        ),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception("API error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
