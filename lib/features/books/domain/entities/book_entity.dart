class BookEntity {
  const BookEntity({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.categoryId,
    required this.coverPath,
    required this.pdfPath,
    required this.pageCount,
    required this.isSeries,
    required this.seriesId,
    required this.volumeNumber,
    required this.volumeCount,
    required this.featured,
    required this.sortOrder,
    required this.authorName,
    required this.publisher,
    required this.isAvailable,
  });

  final String id;

  final String titleArabic;
  final String titleEnglish;

  final String descriptionArabic;
  final String descriptionEnglish;

  final String categoryId;

  final String coverPath;
  final String pdfPath;

  final int pageCount;

  final bool isSeries;

  final String? seriesId;
  final int? volumeNumber;
  final int? volumeCount;

  final bool featured;
  final int sortOrder;

  final String authorName;
  final String publisher;

  final bool isAvailable;
}
