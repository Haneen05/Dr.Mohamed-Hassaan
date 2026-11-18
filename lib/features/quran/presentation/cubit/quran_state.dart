import '../../domain/entities/surah_entity.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranSuccess extends QuranState {
  final List<SurahEntity> surahs;

  QuranSuccess(this.surahs);
}

class QuranEmpty extends QuranState {}

class QuranError extends QuranState {
  final String message;

  QuranError(this.message);
}
