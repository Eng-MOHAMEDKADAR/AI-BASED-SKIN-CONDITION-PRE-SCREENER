import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class ScanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  ScanResult? _lastScan;
  ScanResult? get lastScan => _lastScan;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<ScanResult> scanImage(File imageFile) async {
    _isScanning = true;
    notifyListeners();

    try {
      final ScanResult result = await _apiService.detectDisease(imageFile);
      _lastScan = result;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.saveScan(user.uid, result);
      }

      return result;
    } catch (e) {
      rethrow;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
