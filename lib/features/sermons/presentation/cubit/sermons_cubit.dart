import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/sermons_repository.dart';
import 'sermons_state.dart';

class SermonsCubit extends Cubit<SermonsState> {
  SermonsCubit({required this.repository}) : super(const SermonsInitial());

  final SermonsRepository repository;

  Future<void> getSermons() async {
    emit(const SermonsLoading());

    try {
      final sermons = await repository.getSermons();

      final availableSermons =
          sermons.where((sermon) => sermon.isAvailable).toList(growable: false)
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (availableSermons.isEmpty) {
        emit(const SermonsEmpty());

        return;
      }

      emit(SermonsSuccess(sermons: availableSermons));
    } catch (error) {
      emit(SermonsError(message: error.toString()));
    }
  }
}
