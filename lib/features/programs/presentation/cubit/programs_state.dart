import '../../domain/entities/program_entity.dart';

abstract class ProgramsState {
  const ProgramsState();
}

class ProgramsInitial extends ProgramsState {
  const ProgramsInitial();
}

class ProgramsLoading extends ProgramsState {
  const ProgramsLoading();
}

class ProgramsSuccess extends ProgramsState {
  const ProgramsSuccess({required this.programs});

  final List<ProgramEntity> programs;
}

class ProgramsEmpty extends ProgramsState {
  const ProgramsEmpty();
}

class ProgramsError extends ProgramsState {
  const ProgramsError({required this.message});

  final String message;
}
