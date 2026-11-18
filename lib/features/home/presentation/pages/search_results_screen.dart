import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../books/data/datasources/books_local_data_source.dart';
import '../../../books/domain/entities/book_entity.dart';
import '../../../books/presentation/pages/book_details_screen.dart';
import '../../../programs/data/datasources/programs_local_data_source.dart';
import '../../../programs/domain/entities/episode_entity.dart';
import '../../../programs/domain/entities/program_entity.dart';
import '../../../programs/presentation/pages/program_episodes_screen.dart';
import '../../../programs/presentation/pages/video_player_screen.dart';
import '../../../quran/data/surah/surah_local_data_source.dart';
import '../../../quran/domain/entities/surah_entity.dart';
import '../../../quran/presentation/pages/surah_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, this.showAll = false});

  final bool showAll;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final Future<List<_SearchResult>> _resultsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _resultsFuture = _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_SearchResult>> _loadResults() async {
    final books = await BooksLocalDataSource.instance.getBooks();
    final programs = await ProgramsLocalDataSource.instance.getPrograms();
    final episodes = await ProgramsLocalDataSource.instance.getAllEpisodes();
    final surahs = SurahLocalDataSource.instance.getAllSurahEntities();

    return [
      ...books.where((book) => book.isAvailable).map(_SearchResult.book),
      ...programs
          .where((program) => program.isAvailable)
          .map(_SearchResult.program),
      ...episodes
          .where((episode) => episode.isAvailable)
          .map(_SearchResult.episode),
      ...surahs.map(_SearchResult.surah),
    ];
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  String _titleFor(_SearchResult result, bool isArabic) {
    return switch (result.value) {
      BookEntity book => isArabic ? book.titleArabic : book.titleEnglish,
      ProgramEntity program =>
        isArabic ? program.titleArabic : program.titleEnglish,
      EpisodeEntity episode =>
        isArabic ? episode.titleArabic : episode.titleEnglish,
      SurahEntity surah => isArabic ? surah.nameArabic : surah.nameEnglish,
      _ => '',
    };
  }

  String _kindLabel(_SearchResult result, AppLocalizations localization) {
    return switch (result.kind) {
      _SearchResultKind.book => localization.translate('book'),
      _SearchResultKind.program => localization.translate('programsTitle'),
      _SearchResultKind.episode => localization.translate('episode'),
      _SearchResultKind.surah => localization.translate('surahs'),
    };
  }

  IconData _iconFor(_SearchResultKind kind) {
    return switch (kind) {
      _SearchResultKind.book => Icons.menu_book_rounded,
      _SearchResultKind.program => Icons.ondemand_video_rounded,
      _SearchResultKind.episode => Icons.play_circle_outline_rounded,
      _SearchResultKind.surah => Icons.auto_stories_rounded,
    };
  }

  Future<void> _openResult(_SearchResult result) async {
    final page = switch (result.value) {
      BookEntity book => BookDetailsScreen(book: book),
      ProgramEntity program => ProgramEpisodesScreen(program: program),
      EpisodeEntity episode => VideoPlayerScreen(episode: episode),
      SurahEntity surah => SurahDetailsScreen(surah: surah),
      _ => null,
    };

    if (page == null) {
      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 20, 0),
              child: AppHeader(
                title: localization.translate(
                  widget.showAll ? 'latestContent' : 'searchApp',
                ),
                showBackButton: true,
                onBack: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 12),
              child: AppSearchField(
                controller: _searchController,
                hint: localization.translate('searchApp'),
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<_SearchResult>>(
                future: _resultsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(localization.translate('somethingWentWrong')),
                    );
                  }

                  final query = _normalize(_query);

                  if (query.isEmpty && !widget.showAll) {
                    return Center(
                      child: Text(localization.translate('startSearching')),
                    );
                  }

                  final results = (snapshot.data ?? const <_SearchResult>[])
                      .where(
                        (result) =>
                            query.isEmpty ||
                            _normalize(result.searchText).contains(query),
                      )
                      .toList(growable: false);

                  if (results.isEmpty) {
                    return Center(
                      child: Text(localization.translate('noSearchResults')),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      4,
                      20,
                      28,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final result = results[index];

                      return Material(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _openResult(result),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              14,
                              12,
                              14,
                              12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _iconFor(result.kind),
                                  color: colors.primary,
                                  size: 23,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _titleFor(result, isArabic),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _kindLabel(result, localization),
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? Icons.arrow_back_ios_new_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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

enum _SearchResultKind { book, program, episode, surah }

class _SearchResult {
  const _SearchResult({
    required this.kind,
    required this.value,
    required this.searchText,
  });

  factory _SearchResult.book(BookEntity book) => _SearchResult(
    kind: _SearchResultKind.book,
    value: book,
    searchText:
        '${book.titleArabic} ${book.titleEnglish} '
        '${book.descriptionArabic} ${book.descriptionEnglish} ${book.authorName}',
  );

  factory _SearchResult.program(ProgramEntity program) => _SearchResult(
    kind: _SearchResultKind.program,
    value: program,
    searchText:
        '${program.titleArabic} ${program.titleEnglish} '
        '${program.descriptionArabic} ${program.descriptionEnglish}',
  );

  factory _SearchResult.episode(EpisodeEntity episode) => _SearchResult(
    kind: _SearchResultKind.episode,
    value: episode,
    searchText:
        '${episode.titleArabic} ${episode.titleEnglish} '
        '${episode.descriptionArabic} ${episode.descriptionEnglish}',
  );

  factory _SearchResult.surah(SurahEntity surah) => _SearchResult(
    kind: _SearchResultKind.surah,
    value: surah,
    searchText: '${surah.nameArabic} ${surah.nameEnglish} ${surah.number}',
  );

  final _SearchResultKind kind;
  final Object value;
  final String searchText;
}
