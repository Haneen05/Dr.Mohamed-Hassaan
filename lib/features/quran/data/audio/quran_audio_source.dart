class QuranAudioSource {
  QuranAudioSource._();

  static const String _baseUrl =
      'https://download.tvquran.com/download/'
      'tvQuran.com__Mohamed-Hassan';

  static String getSurahUrl(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(
        surahNumber,
        'surahNumber',
        'Surah number must be between 1 and 114.',
      );
    }

    final fileNumber = surahNumber.toString().padLeft(3, '0');

    return '$_baseUrl/$fileNumber.mp3';
  }
}
