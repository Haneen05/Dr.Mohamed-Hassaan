import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/program_entity.dart';
import '../../domain/repositories/programs_repository.dart';

import '../datasources/programs_local_data_source.dart';

class ProgramsRepositoryImpl implements ProgramsRepository {
  const ProgramsRepositoryImpl({required this.localDataSource});

  final ProgramsLocalDataSource localDataSource;

  @override
  Future<List<ProgramEntity>> getPrograms() {
    return localDataSource.getPrograms();
  }

  @override
  Future<List<EpisodeEntity>> getEpisodes({required String programId}) {
    return localDataSource.getEpisodes(programId: programId);
  }
}
