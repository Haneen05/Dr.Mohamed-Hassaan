import '../../domain/entities/sermon_entity.dart';

abstract class SermonsState {
  const SermonsState();
}

class SermonsInitial extends SermonsState {
  const SermonsInitial();
}

class SermonsLoading extends SermonsState {
  const SermonsLoading();
}

class SermonsSuccess extends SermonsState {
  const SermonsSuccess({required this.sermons});

  final List<SermonEntity> sermons;
}

class SermonsEmpty extends SermonsState {
  const SermonsEmpty();
}

class SermonsError extends SermonsState {
  const SermonsError({required this.message});

  final String message;
}
