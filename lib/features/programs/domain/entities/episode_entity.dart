class EpisodeEntity {
  const EpisodeEntity({
    required this.id,
    required this.programId,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.videoPath,
    required this.thumbnailPath,
    required this.episodeNumber,
    required this.durationSeconds,
    required this.sortOrder,
    required this.isAvailable,
  });

  final String id;

  final String programId;

  final String titleArabic;
  final String titleEnglish;

  final String descriptionArabic;
  final String descriptionEnglish;

  final String videoPath;
  final String thumbnailPath;

  final int episodeNumber;
  final int durationSeconds;
  final int sortOrder;

  final bool isAvailable;
}
