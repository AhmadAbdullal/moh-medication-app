import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Database? _database;

  Future<void> initialize() async {
    _database = await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'medication_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medications(
            id TEXT PRIMARY KEY,
            name TEXT,
            dosage TEXT,
            schedule TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE reminders(
            id TEXT PRIMARY KEY,
            medicationId TEXT,
            time TEXT,
            active INTEGER DEFAULT 1
          )
        ''');
      },
    );
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    return _openDatabase();
  }
}
