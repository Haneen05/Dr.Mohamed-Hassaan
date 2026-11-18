import '../../domain/entities/book_entity.dart';

class BooksLocalDataSource {
  BooksLocalDataSource._();

  static final BooksLocalDataSource instance = BooksLocalDataSource._();

  Future<List<BookEntity>> getBooks() async {
    return const [
      BookEntity(
        id: 'haqiqat_al_tawhid',
        titleArabic: 'حقيقة التوحيد',
        titleEnglish: 'The Reality of Tawhid',
        descriptionArabic:
            'يتناول الشيخ محمد حسان في هذا الكتاب حقيقة التوحيد وأقسامه وأثره في حياة المسلم.',
        descriptionEnglish:
            'A book discussing the meaning and foundations of Tawhid and its impact on the life of a Muslim.',
        categoryId: 'aqeedah',
        coverPath: 'assets/books/covers/aqeedah/haqiqat_al_tawhid/cover.jpg',
        pdfPath: 'assets/books/pdfs/aqeedah/haqiqat_al_tawhid/book.pdf',
        pageCount: 400,
        isSeries: false,
        seriesId: null,
        volumeNumber: null,
        volumeCount: null,
        featured: true,
        sortOrder: 1,
        authorName: 'محمد حسان',
        publisher: 'مكتبة فياض',
        isAvailable: true,
      ),

      BookEntity(
        id: 'ahdath_al_nihaya',
        titleArabic: 'أحداث النهاية',
        titleEnglish: 'Events of the End',
        descriptionArabic:
            'يتناول الشيخ محمد حسان في هذا الكتاب أحداث النهاية وأشراط الساعة وما يتعلق بأحداث آخر الزمان.',
        descriptionEnglish:
            'A book discussing the events of the end times, the signs of the Hour, and events related to the end of the world.',
        categoryId: 'akhirah',
        coverPath: 'assets/books/covers/akhirah/ahdath_al_nihaya/cover.jpg',
        pdfPath: 'assets/books/pdfs/akhirah/ahdath_al_nihaya/book.pdf',
        pageCount: 704,
        isSeries: false,
        seriesId: null,
        volumeNumber: null,
        volumeCount: null,
        featured: false,
        sortOrder: 2,
        authorName: 'محمد حسان',
        publisher: '',
        isAvailable: true,
      ),

      BookEntity(
        id: 'khawatir_ala_tariq_al_dawah',
        titleArabic: 'خواطر على طريق الدعوة',
        titleEnglish: 'Reflections on the Path of Dawah',
        descriptionArabic:
            'خواطر حول طريق الدعوة إلى الله، وما يواجه الدعاة من تحديات، ومسؤولية الدعوة وأثرها في حياة المسلم.',
        descriptionEnglish:
            'Reflections on the path of calling to Allah, the challenges faced by callers, and the responsibility and impact of Dawah in a Muslim’s life.',
        categoryId: 'dawah',
        coverPath:
            'assets/books/covers/dawah/khawatir_ala_tariq_al_dawah/cover.jpg',
        pdfPath: 'assets/books/pdfs/dawah/khawatir_ala_tariq_al_dawah/book.pdf',
        pageCount: 213,
        isSeries: false,
        seriesId: null,
        volumeNumber: null,
        volumeCount: null,
        featured: false,
        sortOrder: 3,
        authorName: 'محمد حسان',
        publisher: 'مكتبة فياض',
        isAvailable: true,
      ),
    ];
  }

  Future<List<BookEntity>> getBooksByCategory({
    required String categoryId,
  }) async {
    final books = await getBooks();

    return books
        .where((book) => book.isAvailable && book.categoryId == categoryId)
        .toList(growable: false);
  }

  Future<List<BookEntity>> getFeaturedBooks() async {
    final books = await getBooks();

    return books
        .where((book) => book.isAvailable && book.featured)
        .toList(growable: false);
  }

  Future<BookEntity?> getBookById({required String bookId}) async {
    final books = await getBooks();

    for (final book in books) {
      if (book.isAvailable && book.id == bookId) {
        return book;
      }
    }

    return null;
  }
}
