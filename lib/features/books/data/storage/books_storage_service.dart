import 'package:firebase_storage/firebase_storage.dart';

class BooksStorageService {
  BooksStorageService(this.storage);

  final FirebaseStorage storage;

  Future<String> getDownloadUrl({required String storagePath}) async {
    if (storagePath.trim().isEmpty) {
      throw ArgumentError('storagePath cannot be empty.');
    }

    final reference = storage.ref(storagePath);

    return reference.getDownloadURL();
  }

  Future<String> getCoverUrl({required String coverPath}) {
    return getDownloadUrl(storagePath: coverPath);
  }

  Future<String> getPdfUrl({required String pdfPath}) {
    return getDownloadUrl(storagePath: pdfPath);
  }

  Future<bool> exists({required String storagePath}) async {
    try {
      final reference = storage.ref(storagePath);

      await reference.getMetadata();

      return true;
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return false;
      }

      rethrow;
    }
  }
}
