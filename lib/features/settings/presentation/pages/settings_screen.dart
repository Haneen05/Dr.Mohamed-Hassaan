import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/locale_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../quran/data/settings/mushaf_settings_local_data_source.dart';
import '../../../quran/presentation/cubit/mushaf_theme_cubit.dart';
import '../../../quran/presentation/cubit/mushaf_theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 20, 0),
              child: AppHeader(
                title: localization.translate('settings'),
                showBackButton: true,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      localization.translate('language'),
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localization.translate('chooseLanguage'),
                      style: AppTextStyles.sectionSubtitle.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, state) {
                        final selectedLanguageCode = context
                            .read<LocaleCubit>()
                            .currentLocale
                            .languageCode;

                        return _SettingsContainer(
                          children: [
                            _LanguageItem(
                              iconText: 'ع',
                              title: localization.translate('arabic'),
                              subtitle: 'العربية',
                              languageCode: 'ar',
                              selectedLanguageCode: selectedLanguageCode,
                              onTap: () {
                                _selectLanguage(context, 'ar');
                              },
                            ),
                            const _SettingsDivider(),
                            _LanguageItem(
                              iconText: 'EN',
                              title: localization.translate('english'),
                              subtitle: 'English',
                              languageCode: 'en',
                              selectedLanguageCode: selectedLanguageCode,
                              onTap: () {
                                _selectLanguage(context, 'en');
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      localization.translate('appearance'),
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localization.translate('chooseAppearance'),
                      style: AppTextStyles.sectionSubtitle.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, state) {
                        return _SettingsContainer(
                          children: [
                            _ThemeItem(
                              icon: Icons.settings_suggest_outlined,
                              title: localization.translate('systemTheme'),
                              subtitle: localization.translate(
                                'systemThemeSubtitle',
                              ),
                              themeMode: ThemeMode.system,
                              selectedThemeMode: state.themeMode,
                              onTap: () {
                                _selectTheme(context, ThemeMode.system);
                              },
                            ),
                            const _SettingsDivider(),
                            _ThemeItem(
                              icon: Icons.light_mode_outlined,
                              title: localization.translate('lightTheme'),
                              subtitle: localization.translate(
                                'lightThemeSubtitle',
                              ),
                              themeMode: ThemeMode.light,
                              selectedThemeMode: state.themeMode,
                              onTap: () {
                                _selectTheme(context, ThemeMode.light);
                              },
                            ),
                            const _SettingsDivider(),
                            _ThemeItem(
                              icon: Icons.dark_mode_outlined,
                              title: localization.translate('darkTheme'),
                              subtitle: localization.translate(
                                'darkThemeSubtitle',
                              ),
                              themeMode: ThemeMode.dark,
                              selectedThemeMode: state.themeMode,
                              onTap: () {
                                _selectTheme(context, ThemeMode.dark);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      localization.translate('mushafReadingMode'),
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localization.translate('chooseMushafReadingMode'),
                      style: AppTextStyles.sectionSubtitle.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<MushafThemeCubit, MushafThemeState>(
                      builder: (context, state) {
                        return _SettingsContainer(
                          children: [
                            _MushafThemeItem(
                              icon: Icons.menu_book_rounded,
                              title: localization.translate(
                                'normalReadingMode',
                              ),
                              subtitle: localization.translate(
                                'normalReadingModeSubtitle',
                              ),
                              readingMode: MushafReadingMode.normal,
                              selectedReadingMode: state.readingMode,
                              onTap: () {
                                _selectMushafTheme(
                                  context,
                                  MushafReadingMode.normal,
                                );
                              },
                            ),
                            const _SettingsDivider(),
                            _MushafThemeItem(
                              icon: Icons.nightlight_outlined,
                              title: localization.translate('nightReadingMode'),
                              subtitle: localization.translate(
                                'nightReadingModeSubtitle',
                              ),
                              readingMode: MushafReadingMode.night,
                              selectedReadingMode: state.readingMode,
                              onTap: () {
                                _selectMushafTheme(
                                  context,
                                  MushafReadingMode.night,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    final localeCubit = context.read<LocaleCubit>();

    if (localeCubit.currentLocale.languageCode == languageCode) {
      return;
    }

    localeCubit.changeLanguage(languageCode);
  }

  void _selectTheme(BuildContext context, ThemeMode themeMode) {
    context.read<ThemeCubit>().changeTheme(themeMode);
  }

  void _selectMushafTheme(BuildContext context, MushafReadingMode readingMode) {
    context.read<MushafThemeCubit>().changeReadingMode(readingMode);
  }
}

class _SettingsContainer extends StatelessWidget {
  const _SettingsContainer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  const _LanguageItem({
    required this.iconText,
    required this.title,
    required this.subtitle,
    required this.languageCode,
    required this.selectedLanguageCode,
    required this.onTap,
  });

  final String iconText;
  final String title;
  final String subtitle;
  final String languageCode;
  final String selectedLanguageCode;
  final VoidCallback onTap;

  bool get isSelected {
    return languageCode == selectedLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SelectionItem(
      leading: Text(
        iconText,
        style: AppTextStyles.label.copyWith(
          color: colorScheme.primary,
          fontSize: languageCode == 'ar' ? 17 : 10,
        ),
      ),
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeMode,
    required this.selectedThemeMode,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode themeMode;
  final ThemeMode selectedThemeMode;
  final VoidCallback onTap;

  bool get isSelected {
    return themeMode == selectedThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SelectionItem(
      leading: Icon(icon, size: 21, color: colorScheme.primary),
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _MushafThemeItem extends StatelessWidget {
  const _MushafThemeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.readingMode,
    required this.selectedReadingMode,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final MushafReadingMode readingMode;
  final MushafReadingMode selectedReadingMode;
  final VoidCallback onTap;

  bool get isSelected {
    return readingMode == selectedReadingMode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SelectionItem(
      leading: Icon(icon, size: 21, color: colorScheme.primary),
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _SelectionItem extends StatelessWidget {
  const _SelectionItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(child: leading),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.smallCaption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
