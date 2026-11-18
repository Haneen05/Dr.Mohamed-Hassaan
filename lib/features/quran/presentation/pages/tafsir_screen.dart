import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/tafsir/tafsir_local_data_source.dart';
import '../../domain/entities/surah_entity.dart';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key, required this.surah});

  final SurahEntity surah;

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  TafsirType _selectedTafsir = TafsirType.saadi;

  late Future<List<_TafsirAyahData>> _tafsirFuture;

  @override
  void initState() {
    super.initState();
    _tafsirFuture = _loadTafsir();
  }

  Future<List<_TafsirAyahData>> _loadTafsir() async {
    final result = <_TafsirAyahData>[];
    final ayahCount = getVerseCount(widget.surah.number);
    final tafsirByAyah = await TafsirLocalDataSource.instance.getTafsirForSurah(
      type: _selectedTafsir,
      surahNumber: widget.surah.number,
    );

    for (var ayahNumber = 1; ayahNumber <= ayahCount; ayahNumber++) {
      result.add(
        _TafsirAyahData(
          surahNumber: widget.surah.number,
          number: ayahNumber,
          tafsir: tafsirByAyah[ayahNumber] ?? '',
        ),
      );
    }

    return result;
  }

  void _changeTafsir(TafsirType type) {
    if (_selectedTafsir == type) {
      return;
    }

    setState(() {
      _selectedTafsir = type;
      _tafsirFuture = _loadTafsir();
    });
  }

  String _currentTafsirTitle(BuildContext context) {
    final localization = AppLocalizations.of(context);

    switch (_selectedTafsir) {
      case TafsirType.saadi:
        return localization.translate('tafsirSaadi');
      case TafsirType.ibnKathir:
        return localization.translate('tafsirIbnKathir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 0),
              child: AppHeader(
                title: _currentTafsirTitle(context),
                subtitle: widget.surah.nameArabic,
                showBackButton: true,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TafsirSelectorButton(
                        title: localization.translate('tafsirSaadi'),
                        selected: _selectedTafsir == TafsirType.saadi,
                        onTap: () {
                          _changeTafsir(TafsirType.saadi);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _TafsirSelectorButton(
                        title: localization.translate('tafsirIbnKathir'),
                        selected: _selectedTafsir == TafsirType.ibnKathir,
                        onTap: () {
                          _changeTafsir(TafsirType.ibnKathir);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<_TafsirAyahData>>(
                future: _tafsirFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return AppStateMessage(
                      icon: Icons.error_outline_rounded,
                      title: localization.translate('tafsirLoadError'),
                      subtitle: '${snapshot.error}',
                      retryLabel: localization.translate('tryAgain'),
                      onRetry: () {
                        setState(() {
                          _tafsirFuture = _loadTafsir();
                        });
                      },
                    );
                  }

                  final ayahs = snapshot.data ?? const <_TafsirAyahData>[];

                  if (ayahs.isEmpty) {
                    return AppStateMessage(
                      icon: Icons.menu_book_outlined,
                      title: localization.translate('noTafsir'),
                      subtitle: localization.translate('noTafsirForSurah'),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      18,
                      4,
                      18,
                      32,
                    ),
                    itemCount: ayahs.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (context, index) {
                      final ayah = ayahs[index];

                      return _TafsirAyahCard(ayah: ayah);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TafsirSelectorButton extends StatelessWidget {
  const _TafsirSelectorButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TafsirAyahData {
  const _TafsirAyahData({
    required this.surahNumber,
    required this.number,
    required this.tafsir,
  });

  final int surahNumber;
  final int number;
  final String tafsir;
}

class _TafsirAyahCard extends StatelessWidget {
  const _TafsirAyahCard({required this.ayah});

  final _TafsirAyahData ayah;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final isDarkMode = theme.brightness == Brightness.dark;

    final displayedAyahNumber = localizedNumber(
      value: ayah.number,
      isArabic: isArabic,
    );

    final tafsirText = ayah.tafsir.trim().isEmpty
        ? localization.translate('noTafsirForAyah')
        : ayah.tafsir;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.secondary),
              ),
              child: Center(
                child: Text(
                  displayedAyahNumber,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: isDarkMode
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                      child: QcfVerse(
                        surahNumber: ayah.surahNumber,
                        verseNumber: ayah.number,
                        sp: 1,
                        h: 1,
                      ),
                    )
                  : QcfVerse(
                      surahNumber: ayah.surahNumber,
                      verseNumber: ayah.number,
                      sp: 1,
                      h: 1,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.secondary.withValues(alpha: 0.40)),
          const SizedBox(height: 14),
          Text(
            tafsirText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              height: 2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
