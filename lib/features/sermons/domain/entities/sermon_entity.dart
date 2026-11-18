class SermonEntity {
  const SermonEntity({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.categoryId,
    required this.videoPath,
    required this.thumbnailPath,
    required this.durationSeconds,
    required this.sortOrder,
    required this.isAvailable,
  });

  final String id;
  final String titleArabic;
  final String titleEnglish;
  final String descriptionArabic;
  final String descriptionEnglish;
  final String categoryId;
  final String videoPath;
  final String thumbnailPath;
  final int durationSeconds;
  final int sortOrder;
  final bool isAvailable;
}
