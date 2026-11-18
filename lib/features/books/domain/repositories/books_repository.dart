import '../entities/book_entity.dart';

abstract class BooksRepository {
  Future<List<BookEntity>> getBooks();

  Future<List<BookEntity>> getBooksByCategory({required String categoryId});

  Future<List<BookEntity>> getFeaturedBooks();
}
