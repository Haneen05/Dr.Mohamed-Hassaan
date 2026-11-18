import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleInitial(const Locale('en'))) {
    _loadSavedLanguage();
  }

  static const _languagePreferenceKey = 'app_language_code';

  Future<void> _loadSavedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languagePreferenceKey);
    if (languageCode == 'ar' || languageCode == 'en') {
      emit(LocaleChanged(Locale(languageCode!)));
    }
  }

  Locale get currentLocale {
    final currentState = state;

    if (currentState is LocaleInitial) {
      return currentState.locale;
    }

    if (currentState is LocaleChanged) {
      return currentState.locale;
    }

    return const Locale('en');
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;
    emit(LocaleChanged(Locale(languageCode)));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languagePreferenceKey, languageCode);
  }

  void toggleLanguage() {
    if (currentLocale.languageCode == 'en') {
      changeLanguage('ar');
    } else {
      changeLanguage('en');
    }
  }
}
