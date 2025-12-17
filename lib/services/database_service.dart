import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_result.dart';
import '../models/remedy_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'crop_detection.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        crop TEXT NOT NULL,
        cropConfidence REAL NOT NULL,
        disease TEXT NOT NULL,
        diseaseConfidence REAL NOT NULL,
        organicSolution TEXT NOT NULL,
        chemicalSolution TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
    
    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_user_timestamp ON scans(userId, timestamp DESC)
    ''');
  }

  Future<int> saveScan(String userId, ScanResult scan) async {
    final db = await database;
    try {
      return await db.insert(
        'scans',
        {
          'userId': userId,
          'crop': scan.crop,
          'cropConfidence': scan.cropConfidence,
          'disease': scan.disease,
          'diseaseConfidence': scan.diseaseConfidence,
          'organicSolution': scan.remedies.organicSolution,
          'chemicalSolution': scan.remedies.chemicalSolution,
          'timestamp': scan.timestamp.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error saving scan to database: $e");
      rethrow;
    }
  }

  Future<List<ScanResult>> getUserScans(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'scans',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return ScanResult(
          id: maps[i]['id'].toString(),
          crop: maps[i]['crop'],
          cropConfidence: maps[i]['cropConfidence'].toDouble(),
          disease: maps[i]['disease'],
          diseaseConfidence: maps[i]['diseaseConfidence'].toDouble(),
          remedies: Remedy(
            organicSolution: maps[i]['organicSolution'],
            chemicalSolution: maps[i]['chemicalSolution'],
          ),
          timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        );
      });
    } catch (e) {
      print("Error getting user scans: $e");
      return [];
    }
  }

  Stream<List<ScanResult>> getUserScansStream(String userId) async* {
    while (true) {
      yield await getUserScans(userId);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllUserScans(String userId) async {
    final db = await database;
    await db.delete(
      'scans',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> getScanCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM scans WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

