import 'package:qcf_quran/qcf_quran.dart';

import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/surah_info.dart';
import 'surah_names.dart';

class SurahLocalDataSource {
  SurahLocalDataSource._();

  static final SurahLocalDataSource instance = SurahLocalDataSource._();

  static const int totalSurahs = 114;

  final Map<int, SurahInfo> _cache = {};

  SurahInfo getSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > totalSurahs) {
      throw ArgumentError.value(
        surahNumber,
        'surahNumber',
        'Surah number must be between 1 and 114.',
      );
    }

    return _cache.putIfAbsent(surahNumber, () => _buildSurahInfo(surahNumber));
  }

  SurahEntity getSurahEntity(int surahNumber) {
    final surah = getSurah(surahNumber);

    return SurahEntity(
      id: 'local_surah_${surah.number}',
      number: surah.number,
      nameArabic: surah.arabicName,
      nameEnglish: surah.englishName,
      revelationType: surah.revelationType,
      numberOfAyahs: surah.ayahCount,
    );
  }

  List<SurahInfo> getAllSurahs() {
    return List.generate(
      totalSurahs,
      (index) => getSurah(index + 1),
      growable: false,
    );
  }

  List<SurahEntity> getAllSurahEntities() {
    return List.generate(
      totalSurahs,
      (index) => getSurahEntity(index + 1),
      growable: false,
    );
  }

  List<SurahInfo> search(String query) {
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) {
      return getAllSurahs();
    }

    return getAllSurahs()
        .where((surah) {
          final arabicName = _normalize(surah.arabicName);
          final englishName = surah.englishName.toLowerCase();
          final number = surah.number.toString();

          return arabicName.contains(normalizedQuery) ||
              englishName.contains(normalizedQuery.toLowerCase()) ||
              number == normalizedQuery;
        })
        .toList(growable: false);
  }

  SurahInfo _buildSurahInfo(int surahNumber) {
    return SurahInfo(
      number: surahNumber,
      arabicName: getSurahNameArabic(surahNumber),
      englishName: getEnglishSurahName(surahNumber),
      ayahCount: getVerseCount(surahNumber),
      revelationType: getPlaceOfRevelation(surahNumber),
      startPage: getPageNumber(surahNumber, 1),
    );
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  void clearCache() {
    _cache.clear();
  }
}
