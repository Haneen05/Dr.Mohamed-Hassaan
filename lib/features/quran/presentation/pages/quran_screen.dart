import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_continue_card.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/reading/last_reading_local_data_source.dart';
import '../../data/surah/surah_local_data_source.dart';
import '../../domain/entities/surah_entity.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/surah_card.dart';
import 'surah_details_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuranCubit>()..getSurahs(),
      child: const _QuranView(),
    );
  }
}

class _QuranView extends StatefulWidget {
  const _QuranView();

  @override
  State<_QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<_QuranView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  late Future<LastReadingRecord?> _lastReadingFuture;

  @override
  void initState() {
    super.initState();
    _loadLastReading();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLastReading() {
    _lastReadingFuture = LastReadingLocalDataSource.instance.getLastReading();
  }

  void _refreshLastReading() {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadLastReading();
    });
  }

  Future<void> _openLastReading(LastReadingRecord record) async {
    final surah = SurahLocalDataSource.instance.getSurahEntity(
      record.surahNumber,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailsScreen(
          surah: surah,
          initialPageNumber: record.pageNumber,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _refreshLastReading();
  }

  Future<void> _openSurah(SurahEntity surah) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurahDetailsScreen(surah: surah)),
    );

    if (!mounted) {
      return;
    }

    _refreshLastReading();
  }

  List<SurahEntity> _filterSurahs(List<SurahEntity> surahs) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return surahs;
    }

    return surahs
        .where((surah) {
          final number = surah.number.toString();
          final arabic = surah.nameArabic.toLowerCase();
          final english = surah.nameEnglish.toLowerCase();

          return number.contains(query) ||
              arabic.contains(query) ||
              english.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 20, 0),
                child: AppHeader(
                  title: localization.translate('quran'),
                  showBackButton: true,
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<LastReadingRecord?>(
                future: _lastReadingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 18);
                  }

                  final lastReading = snapshot.data;

                  if (lastReading == null) {
                    return const SizedBox(height: 4);
                  }

                  final surahInfo = SurahLocalDataSource.instance.getSurah(
                    lastReading.surahNumber,
                  );

                  final surahName = isArabic
                      ? surahInfo.arabicName
                      : surahInfo.englishName;

                  final displayedPageNumber = localizedNumber(
                    value: lastReading.pageNumber,
                    isArabic: isArabic,
                  );

                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 0),
                    child: AppContinueCard(
                      label: localization.translate('continueReading'),
                      title: surahName,
                      meta:
                          '${localization.translate('page')} '
                          '$displayedPageNumber',
                      onTap: () {
                        _openLastReading(lastReading);
                      },
                      leading: Container(
                        color: colorScheme.surfaceContainer,
                        child: Center(
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: colorScheme.primary,
                            size: 27,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 0),
                child: AppSearchField(
                  controller: _searchController,
                  hint: localization.translate('searchSurah'),
                  height: 52,
                  borderRadius: 18,
                  fontSize: 13,
                  hintFontSize: 12,
                  iconSize: 21,
                  blurRadius: 12,
                  shadowOffset: const Offset(0, 4),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClear: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 26, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.translate('surahs'),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    BlocBuilder<QuranCubit, QuranState>(
                      builder: (context, state) {
                        if (state is QuranSuccess) {
                          final filtered = _filterSurahs(state.surahs);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filtered.length} '
                              '${localization.translate('surahs')}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<QuranCubit, QuranState>(
              builder: (context, state) {
                if (state is QuranInitial || state is QuranLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (state is QuranError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.error_outline_rounded,
                      title: localization.translate('somethingWentWrong'),
                      subtitle: state.message,
                      retryLabel: localization.translate('tryAgain'),
                      onRetry: () {
                        context.read<QuranCubit>().getSurahs();
                      },
                    ),
                  );
                }

                if (state is QuranEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.auto_stories_outlined,
                      title: localization.translate('noSurahsYet'),
                      subtitle: localization.translate('quranEmptySubtitle'),
                    ),
                  );
                }

                if (state is QuranSuccess) {
                  final surahs = _filterSurahs(state.surahs);

                  if (surahs.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppStateMessage(
                        icon: Icons.search_off_rounded,
                        title: localization.translate('noSurahsYet'),
                        subtitle: localization.translate('searchSurah'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final surah = surahs[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: SurahCard(
                            surah: surah,
                            onTap: () {
                              _openSurah(surah);
                            },
                          ),
                        );
                      }, childCount: surahs.length),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ],
        ),
      ),
    );
  }
}
