import '../entities/sermon_entity.dart';

abstract class SermonsRepository {
  Future<List<SermonEntity>> getSermons();

  Future<List<SermonEntity>> getSermonsByCategory({required String categoryId});
}
