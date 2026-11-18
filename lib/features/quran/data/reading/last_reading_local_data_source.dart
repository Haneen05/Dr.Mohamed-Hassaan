import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LastReadingRecord {
  const LastReadingRecord({
    required this.pageNumber,
    required this.surahNumber,
    required this.updatedAt,
  });

  final int pageNumber;
  final int surahNumber;
  final DateTime updatedAt;

  factory LastReadingRecord.fromMap(Map<String, Object?> map) {
    return LastReadingRecord(
      pageNumber: map['page_number'] as int,
      surahNumber: map['surah_number'] as int,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class LastReadingLocalDataSource {
  LastReadingLocalDataSource._();

  static final LastReadingLocalDataSource instance =
      LastReadingLocalDataSource._();

  static const String _databaseFileName = 'quran_last_reading.db';

  Database? _database;

  Future<Database> _getDatabase() async {
    _database ??= await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();

    final directory = Directory(p.join(databasesPath, 'quran'));

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final databasePath = p.join(directory.path, _databaseFileName);

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE last_reading (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            page_number INTEGER NOT NULL,
            surah_number INTEGER NOT NULL,
            updated_at TEXT NOT NULL
          )
          ''');
      },
    );
  }

  Future<void> saveLastReading({
    required int pageNumber,
    required int surahNumber,
  }) async {
    final db = await _getDatabase();

    await db.insert('last_reading', {
      'id': 1,
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<LastReadingRecord?> getLastReading() async {
    final db = await _getDatabase();

    final rows = await db.query(
      'last_reading',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return LastReadingRecord.fromMap(rows.first);
  }

  Future<bool> hasLastReading() async {
    return await getLastReading() != null;
  }

  Future<void> clearLastReading() async {
    final db = await _getDatabase();

    await db.delete('last_reading');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
