import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/quran_repository.dart';

import '../surah/surah_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  const QuranRepositoryImpl();

  @override
  Future<List<SurahEntity>> getSurahs() async {
    final localSurahs = SurahLocalDataSource.instance.getAllSurahs();

    return localSurahs
        .map((surah) {
          return SurahEntity(
            id: 'local_surah_${surah.number}',
            number: surah.number,
            nameArabic: surah.arabicName,
            nameEnglish: surah.englishName,
            revelationType: surah.revelationType,
            numberOfAyahs: surah.ayahCount,
          );
        })
        .toList(growable: false);
  }
}
