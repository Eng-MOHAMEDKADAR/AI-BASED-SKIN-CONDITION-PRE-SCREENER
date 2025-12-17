import 'package:flutter/material.dart';

/// 🔹 Global constants for the app
class AppConstants {
  // API
  static const String plantIdApiKey = "YOUR_PLANT_ID_API_KEY"; // 🔑 Replace with real key
  static const String plantIdBaseUrl = "https://api.plant.id/v3/health_assessment";

  // Firestore Collections
  static const String usersCollection = "users";
  static const String scansCollection = "scans";

  // Default Values
  static const String defaultOrganicSolution = "Use neem oil spray or crop rotation.";
  static const String defaultChemicalSolution = "Apply recommended pesticide from local supplier.";
}

/// 🔹 App Colors
class AppColors {
  static const Color primary = Color(0xFF2E7D32); // Green (agriculture vibe)
  static const Color secondary = Color(0xFF66BB6A);
  static const Color accent = Color(0xFFFFC107); // Yellow (farm energy)
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}
