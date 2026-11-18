import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/books_repository.dart';

import '../datasources/books_local_data_source.dart';
import '../datasources/books_remote_data_source.dart';

class BooksRepositoryImpl implements BooksRepository {
  const BooksRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.useLocalData = true,
  });

  final BooksLocalDataSource localDataSource;
  final BooksRemoteDataSource remoteDataSource;

  final bool useLocalData;

  @override
  Future<List<BookEntity>> getBooks() {
    if (useLocalData) {
      return localDataSource.getBooks();
    }

    return remoteDataSource.getBooks();
  }

  @override
  Future<List<BookEntity>> getBooksByCategory({required String categoryId}) {
    if (useLocalData) {
      return localDataSource.getBooksByCategory(categoryId: categoryId);
    }

    return remoteDataSource.getBooksByCategory(categoryId: categoryId);
  }

  @override
  Future<List<BookEntity>> getFeaturedBooks() {
    if (useLocalData) {
      return localDataSource.getFeaturedBooks();
    }

    return remoteDataSource.getFeaturedBooks();
  }
}
