import 'remedy_model.dart';

class ScanResult {
  final String id;
  final String crop;
  final double cropConfidence;
  final String disease;
  final double diseaseConfidence;
  final Remedy remedies;
  final DateTime timestamp;

  double get confidencePercent => diseaseConfidence * 100;
  double get cropConfidencePercent => cropConfidence * 100;

  String get description =>
      "Crop: $crop (${cropConfidencePercent.toStringAsFixed(1)}%)\n\n"
          "Detected Disease: $disease (${confidencePercent.toStringAsFixed(1)}%)\n\n"
          "Organic Solution: ${remedies.organicSolution}\n"
          "Chemical Solution: ${remedies.chemicalSolution}";

  ScanResult({
    this.id = '',
    required this.crop,
    required this.cropConfidence,
    required this.disease,
    required this.diseaseConfidence,
    required this.remedies,
    required this.timestamp,
  });

  // -------------------------------
  // SAVE CONSISTENT CLEAN DATA
  // -------------------------------
  Map<String, dynamic> toMap() {
    return {
      'crop': crop,
      'cropConfidence': cropConfidence,
      'disease': disease,
      'diseaseConfidence': diseaseConfidence,
      'organicSolution': remedies.organicSolution,
      'chemicalSolution': remedies.chemicalSolution,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // -------------------------------
  // CREATE RESULT FROM AI JSON
  // This must match EXACTLY what you save!
  // -------------------------------
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    print("🔍 Parsing JSON in ScanResult.fromJson");
    print("   JSON keys: ${json.keys.toList()}");
    
    final result = json['result'] ?? {};
    print("   Result keys: ${result is Map ? (result as Map).keys.toList() : 'Not a Map'}");
    
    final plantCheck = result is Map ? (result['is_plant'] ?? {}) : {};
    print("   Plant check: $plantCheck");
    
    final diseaseBlock = result is Map ? (result['disease'] ?? {}) : {};
    print("   Disease block: $diseaseBlock");
    
    final suggestions = diseaseBlock is Map 
        ? (diseaseBlock['suggestions'] ?? []) 
        : [];
    print("   Suggestions count: ${suggestions.length}");

    final best = suggestions.isNotEmpty && suggestions is List
        ? suggestions.first 
        : null;
    print("   Best suggestion: $best");

    // FIXED: Unified disease name & probability
    final String diseaseName =
        best is Map ? (best['name']?.toString() ?? 'No Disease Detected') : 'No Disease Detected';
    final double diseaseProb = best is Map
        ? ((best['probability'] ?? 0.0) as num).toDouble()
        : 0.0;

    print("   Disease name: $diseaseName");
    print("   Disease probability: $diseaseProb");

    // FIXED: Unified remedies (DO NOT change later)
    final organic = best is Map && best['organic'] != null
        ? best['organic'].toString()
        : "Apply compost, neem oil, maintain soil health, prune infected parts.";
    final chemical = best is Map && best['chemical'] != null
        ? best['chemical'].toString()
        : "Use recommended fungicides or pesticides as advised.";

    final plantBinary = plantCheck is Map ? (plantCheck['binary'] == true) : false;
    final plantProb = plantCheck is Map 
        ? ((plantCheck['probability'] ?? 0.0) as num).toDouble()
        : 0.0;

    print("   Creating ScanResult object...");
    final scanResult = ScanResult(
      id: '',
      crop: plantBinary ? "Plant" : "Not Plant",
      cropConfidence: plantProb,
      disease: diseaseName,
      diseaseConfidence: diseaseProb,
      remedies: Remedy(
        organicSolution: organic,
        chemicalSolution: chemical,
      ),
      timestamp: DateTime.now(),
    );
    
    print("✅ ScanResult created:");
    print("   Crop: ${scanResult.crop} (${scanResult.cropConfidencePercent}%)");
    print("   Disease: ${scanResult.disease} (${scanResult.confidencePercent}%)");
    
    return scanResult;
  }
}
