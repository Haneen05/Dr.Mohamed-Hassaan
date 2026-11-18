class SurahInfo {
  const SurahInfo({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.ayahCount,
    required this.revelationType,
    required this.startPage,
  });

  final int number;
  final String arabicName;
  final String englishName;
  final int ayahCount;
  final String revelationType;
  final int startPage;

  bool get isMeccan => revelationType.toLowerCase() == 'makkah';

  bool get isMedinan => revelationType.toLowerCase() == 'madinah';
}
