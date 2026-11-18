import '../../domain/entities/book_entity.dart';

abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksSuccess extends BooksState {
  final List<BookEntity> books;

  BooksSuccess(this.books);
}

class BooksEmpty extends BooksState {}

class BooksError extends BooksState {
  final String message;

  BooksError(this.message);
}
