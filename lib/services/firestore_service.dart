// This file is deprecated - use DatabaseService instead
// Keeping for backward compatibility during migration
import '../models/scan_result.dart';
import 'database_service.dart';

class FirestoreService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> saveScan(String userId, ScanResult scan) async {
    await _dbService.saveScan(userId, scan);
  }

  Stream<List<ScanResult>> getUserScans(String userId) {
    return _dbService.getUserScansStream(userId);
  }
}
