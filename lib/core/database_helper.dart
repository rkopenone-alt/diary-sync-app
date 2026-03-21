import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/log_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs (
        uuid TEXT PRIMARY KEY,
        sno INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        whomMet TEXT NOT NULL,
        description TEXT NOT NULL,
        reminderTime TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> getNextSno() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT MAX(sno) as max_sno FROM logs');
    int currentMax = (result.first['max_sno'] as int?) ?? 0;
    return currentMax + 1;
  }

  Future<void> insertLog(LogEntry log) async {
    final db = await instance.database;
    await db.insert('logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LogEntry>> getAllLogs() async {
    final db = await instance.database;
    final result = await db.query('logs', orderBy: 'date DESC, time DESC');
    return result.map((json) => LogEntry.fromMap(json)).toList();
  }

  // Used for syncing
  Future<void> mergeLogs(List<LogEntry> externalLogs) async {
    final db = await instance.database;
    final localLogs = await getAllLogs();
    final localUuids = localLogs.map((e) => e.uuid).toSet();

    Batch batch = db.batch();
    for (var ext in externalLogs) {
      if (!localUuids.contains(ext.uuid)) {
        // Handle sno conflict by assigning new SNO if needed,
        // or just accept external SNO and trust date sorting.
        // For simplicity, we just insert. The UI will sort visually.
        batch.insert('logs', ext.copyWith(isSynced: 1).toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> markAllSynced() async {
     final db = await instance.database;
     await db.rawUpdate('UPDATE logs SET isSynced = 1 WHERE isSynced = 0');
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('logs');
  }
}
