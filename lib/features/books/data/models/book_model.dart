import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.titleArabic,
    required super.titleEnglish,
    required super.descriptionArabic,
    required super.descriptionEnglish,
    required super.categoryId,
    required super.coverPath,
    required super.pdfPath,
    required super.pageCount,
    required super.isSeries,
    required super.seriesId,
    required super.volumeNumber,
    required super.volumeCount,
    required super.featured,
    required super.sortOrder,
    required super.authorName,
    required super.publisher,
    required super.isAvailable,
  });

  factory BookModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return BookModel(
      id: document.id,

      titleArabic: data['titleArabic']?.toString() ?? '',

      titleEnglish: data['titleEnglish']?.toString() ?? '',

      descriptionArabic: data['descriptionArabic']?.toString() ?? '',

      descriptionEnglish: data['descriptionEnglish']?.toString() ?? '',

      categoryId: data['categoryId']?.toString() ?? '',

      coverPath: data['coverPath']?.toString() ?? '',

      pdfPath: data['pdfPath']?.toString() ?? '',

      pageCount: _toInt(data['pageCount']),

      isSeries: _toBool(data['isSeries']),

      seriesId: _toNullableString(data['seriesId']),

      volumeNumber: _toNullableInt(data['volumeNumber']),

      volumeCount: _toNullableInt(data['volumeCount']),

      featured: _toBool(data['featured']),

      sortOrder: _toInt(data['sortOrder']),

      authorName: data['authorName']?.toString() ?? '',

      publisher: data['publisher']?.toString() ?? '',

      isAvailable: data['isAvailable'] == null
          ? true
          : _toBool(data['isAvailable']),
    );
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static String? _toNullableString(Object? value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static bool _toBool(Object? value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }
}
