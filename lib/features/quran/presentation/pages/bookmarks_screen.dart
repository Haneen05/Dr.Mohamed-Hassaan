import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/bookmarks/bookmark_local_data_source.dart';
import '../../data/surah/surah_local_data_source.dart';
import '../../domain/entities/surah_entity.dart';
import 'surah_details_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<List<BookmarkRecord>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _bookmarksFuture = BookmarkLocalDataSource.instance.getBookmarks();
  }

  Future<void> _refresh() async {
    setState(_loadBookmarks);
    await _bookmarksFuture;
  }

  Future<void> _removeBookmark(BookmarkRecord bookmark) async {
    await BookmarkLocalDataSource.instance.removeBookmark(bookmark.pageNumber);

    if (!mounted) {
      return;
    }

    setState(_loadBookmarks);
  }

  SurahEntity _buildSurahEntity(int surahNumber) {
    final info = SurahLocalDataSource.instance.getSurah(surahNumber);

    return SurahEntity(
      id: 'local_surah_${info.number}',
      number: info.number,
      nameArabic: info.arabicName,
      nameEnglish: info.englishName,
      revelationType: info.revelationType,
      numberOfAyahs: info.ayahCount,
    );
  }

  Future<void> _openBookmark(BookmarkRecord bookmark) async {
    final surah = _buildSurahEntity(bookmark.surahNumber);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailsScreen(
          surah: surah,
          initialPageNumber: bookmark.pageNumber,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_loadBookmarks);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 12),
              child: AppHeader(
                title: localization.translate('savedPages'),
                showBackButton: true,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<BookmarkRecord>>(
                future: _bookmarksFuture,
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
                      title: localization.translate('bookmarkLoadError'),
                      subtitle: localization.translate('bookmarkLoadError'),
                      retryLabel: localization.translate('tryAgain'),
                      onRetry: () {
                        setState(_loadBookmarks);
                      },
                    );
                  }

                  final bookmarks = snapshot.data ?? const <BookmarkRecord>[];

                  if (bookmarks.isEmpty) {
                    return AppStateMessage(
                      icon: Icons.bookmark_border_rounded,
                      title: localization.translate('noBookmarks'),
                      subtitle: localization.translate('noBookmarksSubtitle'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: colorScheme.primary,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 18, 30),
                      itemCount: bookmarks.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];

                        final surahInfo = SurahLocalDataSource.instance
                            .getSurah(bookmark.surahNumber);

                        final surahName = isArabic
                            ? surahInfo.arabicName
                            : surahInfo.englishName;

                        return _BookmarkCard(
                          surahName: surahName,
                          pageNumber: bookmark.pageNumber,
                          isArabic: isArabic,
                          pageLabel: localization.translate('page'),
                          onTap: () {
                            _openBookmark(bookmark);
                          },
                          onDelete: () {
                            _removeBookmark(bookmark);
                          },
                        );
                      },
                    ),
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

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.surahName,
    required this.pageNumber,
    required this.isArabic,
    required this.pageLabel,
    required this.onTap,
    required this.onDelete,
  });

  final String surahName;
  final int pageNumber;
  final bool isArabic;
  final String pageLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final displayedPageNumber = localizedNumber(
      value: pageNumber,
      isArabic: isArabic,
    );

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$pageLabel $displayedPageNumber',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
