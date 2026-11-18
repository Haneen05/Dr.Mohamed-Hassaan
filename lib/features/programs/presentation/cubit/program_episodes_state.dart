import '../../domain/entities/episode_entity.dart';

abstract class ProgramEpisodesState {
  const ProgramEpisodesState();
}

class ProgramEpisodesInitial extends ProgramEpisodesState {
  const ProgramEpisodesInitial();
}

class ProgramEpisodesLoading extends ProgramEpisodesState {
  const ProgramEpisodesLoading();
}

class ProgramEpisodesSuccess extends ProgramEpisodesState {
  const ProgramEpisodesSuccess({required this.episodes});

  final List<EpisodeEntity> episodes;
}

class ProgramEpisodesEmpty extends ProgramEpisodesState {
  const ProgramEpisodesEmpty();
}

class ProgramEpisodesError extends ProgramEpisodesState {
  const ProgramEpisodesError({required this.message});

  final String message;
}
