import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

enum TafsirType { saadi, ibnKathir }

class TafsirLocalDataSource {
  TafsirLocalDataSource._();

  static final TafsirLocalDataSource instance = TafsirLocalDataSource._();

  static const String _saadiAssetPath =
      'assets/quran/tafsir/ar-tafseer-al-saddi.db';

  static const String _ibnKathirAssetPath =
      'assets/quran/tafsir/ar-tafsir-ibn-kathir.db';

  static const String _saadiDbFileName = 'ar-tafseer-al-saddi.db';

  static const String _ibnKathirDbFileName = 'ar-tafsir-ibn-kathir.db';

  Database? _saadiDb;
  Database? _ibnKathirDb;
  final Map<TafsirType, Map<String, String>> _tafsirCache = {};

  Future<String?> getTafsir({
    required TafsirType type,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return (await getTafsirForSurah(
      type: type,
      surahNumber: surahNumber,
    ))[ayahNumber];
  }

  Future<Map<int, String>> getTafsirForSurah({
    required TafsirType type,
    required int surahNumber,
  }) async {
    final cache = await _getTafsirIndex(type);
    final prefix = '$surahNumber:';
    return {
      for (final entry in cache.entries)
        if (entry.key.startsWith(prefix))
          int.parse(entry.key.substring(prefix.length)): entry.value,
    };
  }

  Future<Map<String, String>> _getTafsirIndex(TafsirType type) async {
    final cached = _tafsirCache[type];
    if (cached != null) return cached;

    final db = await _getDatabase(type);
    final rows = await db.query(
      'tafsir',
      columns: ['ayah_key', 'ayah_keys', 'text'],
    );
    final index = <String, String>{};
    for (final row in rows) {
      final text = _cleanText(row['text']?.toString());
      if (text == null) continue;
      final exactKey = row['ayah_key']?.toString();
      if (exactKey != null && exactKey.contains(':')) index[exactKey] = text;
      final groupedKeys = row['ayah_keys']?.toString();
      if (groupedKeys != null && groupedKeys.isNotEmpty) {
        final normalized = groupedKeys
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .replaceAll("'", '');
        for (final key in normalized.split(',').map((key) => key.trim())) {
          if (key.contains(':')) index.putIfAbsent(key, () => text);
        }
      }
    }
    _tafsirCache[type] = index;
    return index;
  }

  Future<Database> _getDatabase(TafsirType type) async {
    switch (type) {
      case TafsirType.saadi:
        _saadiDb ??= await _openAssetDatabase(
          assetPath: _saadiAssetPath,
          fileName: _saadiDbFileName,
        );

        return _saadiDb!;

      case TafsirType.ibnKathir:
        _ibnKathirDb ??= await _openAssetDatabase(
          assetPath: _ibnKathirAssetPath,
          fileName: _ibnKathirDbFileName,
        );

        return _ibnKathirDb!;
    }
  }

  Future<Database> _openAssetDatabase({
    required String assetPath,
    required String fileName,
  }) async {
    final databasesPath = await getDatabasesPath();

    final directory = Directory(p.join(databasesPath, 'quran', 'tafsir'));

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final databasePath = p.join(directory.path, fileName);

    final databaseFile = File(databasePath);

    if (!await databaseFile.exists()) {
      final data = await rootBundle.load(assetPath);

      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await databaseFile.writeAsBytes(bytes, flush: true);
    }

    return openDatabase(databasePath, readOnly: true);
  }

  String? _cleanText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    var text = value;

    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');

    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  Future<void> close() async {
    await _saadiDb?.close();
    await _ibnKathirDb?.close();

    _saadiDb = null;
    _ibnKathirDb = null;
    _tafsirCache.clear();
  }
}
