import '../../domain/entities/sermon_entity.dart';

class SermonsLocalDataSource {
  SermonsLocalDataSource._();

  static final SermonsLocalDataSource instance = SermonsLocalDataSource._();

  Future<List<SermonEntity>> getSermons() async {
    return const [];
  }

  Future<List<SermonEntity>> getSermonsByCategory({
    required String categoryId,
  }) async {
    final sermons = await getSermons();

    return sermons
        .where(
          (sermon) => sermon.isAvailable && sermon.categoryId == categoryId,
        )
        .toList(growable: false);
  }
}
