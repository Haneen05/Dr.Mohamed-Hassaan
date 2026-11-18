import 'package:shared_preferences/shared_preferences.dart';

enum MushafReadingMode { normal, night }

class MushafSettingsLocalDataSource {
  MushafSettingsLocalDataSource._();

  static final MushafSettingsLocalDataSource instance =
      MushafSettingsLocalDataSource._();

  static const String _readingModeKey = 'mushaf_reading_mode';

  Future<MushafReadingMode> getReadingMode() async {
    final preferences = await SharedPreferences.getInstance();

    final savedMode = preferences.getString(_readingModeKey);

    if (savedMode == MushafReadingMode.night.name) {
      return MushafReadingMode.night;
    }

    return MushafReadingMode.normal;
  }

  Future<void> saveReadingMode(MushafReadingMode mode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_readingModeKey, mode.name);
  }
}
