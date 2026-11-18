import 'package:shared_preferences/shared_preferences.dart';

class BooksReadingRecord {
  const BooksReadingRecord({required this.bookId, required this.pageNumber});

  final String bookId;
  final int pageNumber;
}

class BooksReadingLocalDataSource {
  BooksReadingLocalDataSource._();

  static final BooksReadingLocalDataSource instance =
      BooksReadingLocalDataSource._();

  static const String _lastBookIdKey = 'books_last_read_book_id';

  String _pageKey(String bookId) {
    return 'book_last_page_$bookId';
  }

  Future<BooksReadingRecord?> getLastReading() async {
    final prefs = await SharedPreferences.getInstance();

    final bookId = prefs.getString(_lastBookIdKey);

    if (bookId == null || bookId.trim().isEmpty) {
      return null;
    }

    final page = prefs.getInt(_pageKey(bookId)) ?? 1;

    return BooksReadingRecord(bookId: bookId, pageNumber: page > 0 ? page : 1);
  }

  Future<int> getBookPage({required String bookId}) async {
    final prefs = await SharedPreferences.getInstance();

    final page = prefs.getInt(_pageKey(bookId)) ?? 1;

    return page > 0 ? page : 1;
  }

  Future<void> saveReading({
    required String bookId,
    required int pageNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final page = pageNumber > 0 ? pageNumber : 1;

    await prefs.setInt(_pageKey(bookId), page);

    await prefs.setString(_lastBookIdKey, bookId);
  }
}
