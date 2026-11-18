import '../entities/episode_entity.dart';
import '../entities/program_entity.dart';

abstract class ProgramsRepository {
  Future<List<ProgramEntity>> getPrograms();

  Future<List<EpisodeEntity>> getEpisodes({required String programId});
}
