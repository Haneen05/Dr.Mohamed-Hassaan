import '../../data/settings/mushaf_settings_local_data_source.dart';

class MushafThemeState {
  const MushafThemeState({required this.readingMode, required this.isLoaded});

  const MushafThemeState.initial()
    : readingMode = MushafReadingMode.normal,
      isLoaded = false;

  final MushafReadingMode readingMode;
  final bool isLoaded;

  bool get isNightMode => readingMode == MushafReadingMode.night;

  MushafThemeState copyWith({MushafReadingMode? readingMode, bool? isLoaded}) {
    return MushafThemeState(
      readingMode: readingMode ?? this.readingMode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
