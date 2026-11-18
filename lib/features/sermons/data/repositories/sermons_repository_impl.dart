import '../../domain/entities/sermon_entity.dart';
import '../../domain/repositories/sermons_repository.dart';
import '../datasources/sermons_local_data_source.dart';

class SermonsRepositoryImpl implements SermonsRepository {
  const SermonsRepositoryImpl({required this.localDataSource});

  final SermonsLocalDataSource localDataSource;

  @override
  Future<List<SermonEntity>> getSermons() {
    return localDataSource.getSermons();
  }

  @override
  Future<List<SermonEntity>> getSermonsByCategory({
    required String categoryId,
  }) {
    return localDataSource.getSermonsByCategory(categoryId: categoryId);
  }
}
