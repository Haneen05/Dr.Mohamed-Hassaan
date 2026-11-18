import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/surah/surah_local_data_source.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/surah_info.dart';
import '../pages/bookmarks_screen.dart';
import '../pages/tafsir_screen.dart';
import 'quran_audio_player.dart';

class SurahSideMenu extends StatefulWidget {
  const SurahSideMenu({
    super.key,
    required this.surah,
    required this.audioPlayer,
    required this.isLoadingAudio,
    required this.onToggleAudio,
  });

  final SurahEntity surah;
  final AudioPlayer audioPlayer;
  final bool isLoadingAudio;
  final Future<void> Function() onToggleAudio;

  @override
  State<SurahSideMenu> createState() => _SurahSideMenuState();
}

class _SurahSideMenuState extends State<SurahSideMenu> {
  bool _showTafsir = true;
  bool _showInfo = true;
  bool _showAudio = true;

  late SurahInfo _localSurahInfo;

  @override
  void initState() {
    super.initState();

    _localSurahInfo = SurahLocalDataSource.instance.getSurah(
      widget.surah.number,
    );
  }

  @override
  void didUpdateWidget(covariant SurahSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.surah.number != widget.surah.number) {
      _localSurahInfo = SurahLocalDataSource.instance.getSurah(
        widget.surah.number,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(26),
          bottomStart: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close_rounded, color: colorScheme.primary),
                  ),
                  Expanded(
                    child: Text(
                      localization.translate('menu'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 8),
              _MenuSectionHeader(
                icon: Icons.menu_book_rounded,
                title: localization.translate('tafsir'),
                expanded: _showTafsir,
                onTap: () {
                  setState(() {
                    _showTafsir = !_showTafsir;
                  });
                },
              ),
              if (_showTafsir) ...[
                const SizedBox(height: 10),
                _MenuItem(
                  icon: Icons.menu_book_outlined,
                  title: localization.translate('tafsir'),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TafsirScreen(surah: widget.surah),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 8),
              _MenuItem(
                icon: Icons.bookmarks_rounded,
                title: localization.translate('bookmarks'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 8),
              _MenuSectionHeader(
                icon: Icons.info_outline_rounded,
                title: localization.translate('surahInformation'),
                expanded: _showInfo,
                onTap: () {
                  setState(() {
                    _showInfo = !_showInfo;
                  });
                },
              ),
              if (_showInfo) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  label: localization.translate('ayahCount'),
                  value: localizedNumber(
                    value: _localSurahInfo.ayahCount,
                    isArabic: isArabic,
                  ),
                ),
                _InfoRow(
                  label: localization.translate('surahNumber'),
                  value: localizedNumber(
                    value: _localSurahInfo.number,
                    isArabic: isArabic,
                  ),
                ),
                _InfoRow(
                  label: localization.translate('revelationType'),
                  value: _formatRevelationType(
                    context,
                    _localSurahInfo.revelationType,
                  ),
                ),
                _InfoRow(
                  label: localization.translate('startPage'),
                  value: localizedNumber(
                    value: _localSurahInfo.startPage,
                    isArabic: isArabic,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 8),
              _MenuSectionHeader(
                icon: Icons.headphones_rounded,
                title: localization.translate('listen'),
                expanded: _showAudio,
                onTap: () {
                  setState(() {
                    _showAudio = !_showAudio;
                  });
                },
              ),
              if (_showAudio) ...[
                const SizedBox(height: 12),
                QuranAudioPlayer(
                  audioPlayer: widget.audioPlayer,
                  surah: widget.surah,
                  isLoadingAudio: widget.isLoadingAudio,
                  onToggleAudio: widget.onToggleAudio,
                  listenText: localization.translate('listenWhileReading'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatRevelationType(BuildContext context, String value) {
    final localization = AppLocalizations.of(context);
    final normalized = value.toLowerCase().trim();

    if (normalized == 'makkah' ||
        normalized == 'meccan' ||
        normalized == 'mecca') {
      return localization.translate('meccan');
    }

    if (normalized == 'madinah' ||
        normalized == 'medinan' ||
        normalized == 'medina') {
      return localization.translate('medinan');
    }

    return value;
  }
}

class _MenuSectionHeader extends StatelessWidget {
  const _MenuSectionHeader({
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                isRtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
