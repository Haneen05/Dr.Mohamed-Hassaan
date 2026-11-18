class ProgramEntity {
  const ProgramEntity({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.thumbnailPath,
    required this.episodeCount,
    required this.sortOrder,
    required this.isAvailable,
  });

  final String id;

  final String titleArabic;
  final String titleEnglish;

  final String descriptionArabic;
  final String descriptionEnglish;

  final String thumbnailPath;

  final int episodeCount;
  final int sortOrder;

  final bool isAvailable;
}
