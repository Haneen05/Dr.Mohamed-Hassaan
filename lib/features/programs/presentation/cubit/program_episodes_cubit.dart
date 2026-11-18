import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/programs_repository.dart';
import 'program_episodes_state.dart';

class ProgramEpisodesCubit extends Cubit<ProgramEpisodesState> {
  ProgramEpisodesCubit({required this.repository})
    : super(const ProgramEpisodesInitial());

  final ProgramsRepository repository;

  Future<void> getEpisodes({required String programId}) async {
    emit(const ProgramEpisodesLoading());

    try {
      final episodes = await repository.getEpisodes(programId: programId);

      if (episodes.isEmpty) {
        emit(const ProgramEpisodesEmpty());

        return;
      }

      emit(ProgramEpisodesSuccess(episodes: episodes));
    } catch (error) {
      emit(ProgramEpisodesError(message: error.toString()));
    }
  }
}
