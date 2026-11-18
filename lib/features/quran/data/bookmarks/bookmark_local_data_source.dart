import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BookmarkRecord {
  const BookmarkRecord({
    required this.id,
    required this.pageNumber,
    required this.surahNumber,
    required this.createdAt,
  });

  final int id;
  final int pageNumber;
  final int surahNumber;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookmarkRecord.fromMap(Map<String, Object?> map) {
    return BookmarkRecord(
      id: map['id'] as int,
      pageNumber: map['page_number'] as int,
      surahNumber: map['surah_number'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class BookmarkLocalDataSource {
  BookmarkLocalDataSource._();

  static final BookmarkLocalDataSource instance = BookmarkLocalDataSource._();

  static const String _databaseFileName = 'quran_bookmarks.db';

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
          CREATE TABLE bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            page_number INTEGER NOT NULL UNIQUE,
            surah_number INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
          ''');
      },
    );
  }

  Future<List<BookmarkRecord>> getBookmarks() async {
    final db = await _getDatabase();

    final rows = await db.query('bookmarks', orderBy: 'created_at DESC');

    return rows.map(BookmarkRecord.fromMap).toList(growable: false);
  }

  Future<bool> isBookmarked(int pageNumber) async {
    final db = await _getDatabase();

    final rows = await db.query(
      'bookmarks',
      columns: ['id'],
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<void> addBookmark({
    required int pageNumber,
    required int surahNumber,
  }) async {
    final db = await _getDatabase();

    await db.insert('bookmarks', {
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeBookmark(int pageNumber) async {
    final db = await _getDatabase();

    await db.delete(
      'bookmarks',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
    );
  }

  Future<bool> toggleBookmark({
    required int pageNumber,
    required int surahNumber,
  }) async {
    final bookmarked = await isBookmarked(pageNumber);

    if (bookmarked) {
      await removeBookmark(pageNumber);

      return false;
    }

    await addBookmark(pageNumber: pageNumber, surahNumber: surahNumber);

    return true;
  }

  Future<void> clearBookmarks() async {
    final db = await _getDatabase();

    await db.delete('bookmarks');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
