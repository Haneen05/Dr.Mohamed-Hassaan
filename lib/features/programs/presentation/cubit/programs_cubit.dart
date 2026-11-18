import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/programs_repository.dart';
import 'programs_state.dart';

class ProgramsCubit extends Cubit<ProgramsState> {
  ProgramsCubit({required this.repository}) : super(const ProgramsInitial());

  final ProgramsRepository repository;

  Future<void> getPrograms() async {
    emit(const ProgramsLoading());

    try {
      final programs = await repository.getPrograms();

      final availablePrograms =
          programs
              .where((program) => program.isAvailable)
              .toList(growable: false)
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (availablePrograms.isEmpty) {
        emit(const ProgramsEmpty());

        return;
      }

      emit(ProgramsSuccess(programs: availablePrograms));
    } catch (error) {
      emit(ProgramsError(message: error.toString()));
    }
  }
}
