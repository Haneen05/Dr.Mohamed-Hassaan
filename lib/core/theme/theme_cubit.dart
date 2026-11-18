import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _loadTheme();
  }

  static const String _themeModeKey = 'theme_mode';

  ThemeMode get currentThemeMode => state.themeMode;

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(_themeModeKey);

    final themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    emit(ThemeState(themeMode));
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    if (state.themeMode == themeMode) {
      return;
    }

    emit(ThemeState(themeMode));

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_themeModeKey, switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}
