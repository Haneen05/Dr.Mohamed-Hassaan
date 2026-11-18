import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository repository;

  QuranCubit(this.repository) : super(QuranInitial());

  Future<void> getSurahs() async {
    emit(QuranLoading());

    try {
      final surahs = await repository.getSurahs();

      if (surahs.isEmpty) {
        emit(QuranEmpty());
      } else {
        emit(QuranSuccess(surahs));
      }
    } catch (e) {
      debugPrint('Quran error: $e');

      emit(QuranError(e.toString()));
    }
  }
}
