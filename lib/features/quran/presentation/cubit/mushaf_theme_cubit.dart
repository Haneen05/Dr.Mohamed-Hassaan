import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings/mushaf_settings_local_data_source.dart';
import 'mushaf_theme_state.dart';

class MushafThemeCubit extends Cubit<MushafThemeState> {
  MushafThemeCubit({required MushafSettingsLocalDataSource localDataSource})
    : this._(localDataSource);

  MushafThemeCubit._(this._localDataSource)
    : super(const MushafThemeState.initial());

  final MushafSettingsLocalDataSource _localDataSource;

  Future<void> load() async {
    final readingMode = await _localDataSource.getReadingMode();

    emit(MushafThemeState(readingMode: readingMode, isLoaded: true));
  }

  Future<void> changeReadingMode(MushafReadingMode readingMode) async {
    if (state.readingMode == readingMode) {
      return;
    }

    await _localDataSource.saveReadingMode(readingMode);

    emit(state.copyWith(readingMode: readingMode, isLoaded: true));
  }
}
