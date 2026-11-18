class SurahEntity {
  const SurahEntity({
    required this.id,
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  final String id;
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String revelationType;
  final int numberOfAyahs;
}
