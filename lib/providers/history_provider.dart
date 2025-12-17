import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/firestore_service.dart';

class HistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<ScanResult>> getUserHistory(String userId) {
    return _firestoreService.getUserScans(userId);
  }
}

