import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';

class ApiService {
  // 🔑 Your Kindwise Crop.Health API key
  static const String apiKey = "wsze24ijsY6sajreuYxEgnsaS1rBQyLLX3tBfBGwyWO3FvrHBA";

  // 🌐 Kindwise disease detection endpoint
  static const String baseUrl = "https://crop.kindwise.com/api/v1/identification";

  /// 🌾 Detect plant disease using Kindwise Crop.Health API
  Future<ScanResult> detectDisease(File imageFile) async {
    final uri = Uri.parse(baseUrl);

    try {
      final request = http.MultipartRequest("POST", uri)
        ..headers.addAll({
          "Api-Key": apiKey,
          "Accept": "application/json",
        })
        ..files.add(await http.MultipartFile.fromPath("image", imageFile.path));

      print("🛰️ Sending request to: $uri");
      print("📦 Headers: ${request.headers}");
      print("📁 File: ${imageFile.path}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("✅ Status: ${response.statusCode}");
      print("📨 Response: ${response.body}");

      // ✅ Kindwise usually returns 200 or 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          print("📝 Parsing JSON response...");
          final data = jsonDecode(response.body);
          print("✅ JSON decoded successfully");
          print("   Data type: ${data.runtimeType}");
          print("   Data keys: ${data is Map ? (data as Map).keys.toList() : 'N/A'}");

          // Safely handle unexpected structures
          if (data is Map<String, dynamic>) {
            try {
              print("🔄 Creating ScanResult from JSON...");
              final result = ScanResult.fromJson(data);
              print("✅ ScanResult created successfully:");
              print("   Disease: ${result.disease}");
              print("   Confidence: ${result.confidencePercent}%");
              print("   Crop: ${result.crop}");
              return result;
            } catch (e, stackTrace) {
              print("❌ Error parsing ScanResult from JSON: $e");
              print("Stack trace: $stackTrace");
              print("JSON data structure: $data");
              throw Exception("Failed to parse API response: $e");
            }
          } else {
            throw Exception("Unexpected API response format. Expected Map, got ${data.runtimeType}");
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception("Error decoding API response: $e");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Invalid API key or unauthorized access.");
      } else if (response.statusCode == 413) {
        throw Exception("Uploaded image too large. Please use a smaller file.");
      } else if (response.statusCode == 415) {
        throw Exception("Unsupported image format. Please upload JPG or PNG.");
      } else {
        throw Exception(
          "Kindwise API error ${response.statusCode}: ${response.reasonPhrase}\nBody: ${response.body}",
        );
      }
    } on SocketException {
      throw Exception("No Internet connection. Please check your network.");
    } on FormatException {
      throw Exception("Invalid response format from the server.");
    } catch (e) {
      throw Exception("Error detecting disease: $e");
    }
  }
}
