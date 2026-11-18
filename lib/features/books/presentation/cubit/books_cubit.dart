import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/books_repository.dart';
import 'books_state.dart';

class BooksCubit extends Cubit<BooksState> {
  BooksCubit(this.repository) : super(BooksInitial());

  final BooksRepository repository;

  Future<void> getBooks() async {
    emit(BooksLoading());

    try {
      final books = await repository.getBooks();

      if (books.isEmpty) {
        emit(BooksEmpty());

        return;
      }

      emit(BooksSuccess(books));
    } catch (error) {
      debugPrint('BOOKS ERROR: $error');

      emit(BooksError(error.toString()));
    }
  }

  Future<void> getBooksByCategory({required String categoryId}) async {
    emit(BooksLoading());

    try {
      final books = await repository.getBooksByCategory(categoryId: categoryId);

      if (books.isEmpty) {
        emit(BooksEmpty());

        return;
      }

      emit(BooksSuccess(books));
    } catch (error) {
      debugPrint('BOOKS CATEGORY ERROR: $error');

      emit(BooksError(error.toString()));
    }
  }

  Future<List<BookEntity>> getFeaturedBooks() async {
    try {
      return await repository.getFeaturedBooks();
    } catch (error) {
      debugPrint('FEATURED BOOKS ERROR: $error');

      return const [];
    }
  }
}
