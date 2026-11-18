import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book_model.dart';

class BooksRemoteDataSource {
  BooksRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<BookModel>> getBooks() async {
    final snapshot = await firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    return snapshot.docs.map(BookModel.fromFirestore).toList(growable: false);
  }

  Future<List<BookModel>> getBooksByCategory({
    required String categoryId,
  }) async {
    final snapshot = await firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('sortOrder')
        .get();

    return snapshot.docs.map(BookModel.fromFirestore).toList(growable: false);
  }

  Future<List<BookModel>> getFeaturedBooks() async {
    final snapshot = await firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .where('featured', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    return snapshot.docs.map(BookModel.fromFirestore).toList(growable: false);
  }
}
