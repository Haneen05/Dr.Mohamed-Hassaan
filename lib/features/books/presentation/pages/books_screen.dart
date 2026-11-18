import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_category_chip.dart';
import '../../../../core/widgets/app_continue_card.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_media_thumbnail.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/reading/books_reading_local_data_source.dart';
import '../../domain/entities/book_entity.dart';
import '../cubit/books_cubit.dart';
import '../cubit/books_state.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';
import 'book_reader_screen.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BooksCubit>()..getBooks(),
      child: _BooksView(onBack: onBack),
    );
  }
}

class _BooksView extends StatefulWidget {
  const _BooksView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<_BooksView> {
  final TextEditingController _searchController = TextEditingController();
  double? _backSwipeStartX;
  double _backSwipeOffset = 0;

  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  String? _lastBookId;
  int _lastPage = 1;

  static const List<_BookCategory> _categories = [
    _BookCategory(id: 'all', localizationKey: 'allCategory'),
    _BookCategory(id: 'aqeedah', localizationKey: 'aqeedahCategory'),
    _BookCategory(
      id: 'quran_tafsir',
      localizationKey: 'quranTafsirCategoryBooks',
    ),
    _BookCategory(
      id: 'seerah_history',
      localizationKey: 'seerahHistoryCategory',
    ),
    _BookCategory(id: 'hadith', localizationKey: 'hadithCategory'),
    _BookCategory(id: 'fiqh', localizationKey: 'fiqhCategory'),
    _BookCategory(id: 'dawah', localizationKey: 'dawahCategory'),
    _BookCategory(
      id: 'education_ethics',
      localizationKey: 'educationEthicsCategory',
    ),
    _BookCategory(id: 'akhirah', localizationKey: 'akhirahCategory'),
  ];

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

  Future<void> _loadLastReading() async {
    final record = await BooksReadingLocalDataSource.instance.getLastReading();

    if (!mounted) {
      return;
    }

    setState(() {
      _lastBookId = record?.bookId;
      _lastPage = record?.pageNumber ?? 1;
    });
  }

  List<BookEntity> _filterBooks(List<BookEntity> books) {
    final query = _searchQuery.trim().toLowerCase();

    return books
        .where((book) {
          final matchesCategory =
              _selectedCategoryId == 'all' ||
              book.categoryId == _selectedCategoryId;

          if (!matchesCategory) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          return book.titleArabic.toLowerCase().contains(query) ||
              book.titleEnglish.toLowerCase().contains(query) ||
              book.authorName.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  BookEntity? _findLastBook(List<BookEntity> books) {
    final lastBookId = _lastBookId;

    if (lastBookId == null) {
      return null;
    }

    for (final book in books) {
      if (book.id == lastBookId) {
        return book;
      }
    }

    return null;
  }

  Future<void> _openBookDetails(BookEntity book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book)),
    );

    if (!mounted) {
      return;
    }

    await _loadLastReading();
  }

  Future<void> _continueReading(BookEntity book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
    );

    if (!mounted) {
      return;
    }

    await _loadLastReading();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (details) {
          _backSwipeStartX = details.globalPosition.dx <= 56
              ? details.globalPosition.dx
              : null;
        },
        onHorizontalDragUpdate: (details) {
          if (_backSwipeStartX != null) {
            setState(
              () => _backSwipeOffset = (_backSwipeOffset + details.delta.dx)
                  .clamp(0, MediaQuery.sizeOf(context).width),
            );
          }
        },
        onHorizontalDragEnd: (details) {
          final shouldGoBack =
              _backSwipeOffset > MediaQuery.sizeOf(context).width * .12 ||
              (details.primaryVelocity ?? 0) > 150;
          if (_backSwipeStartX != null && shouldGoBack) {
            setState(() => _backSwipeOffset = 0);
            widget.onBack?.call();
          } else {
            setState(() => _backSwipeOffset = 0);
          }
          _backSwipeStartX = null;
        },
        child: AnimatedContainer(
          duration: _backSwipeStartX == null
              ? const Duration(milliseconds: 220)
              : Duration.zero,
          transform: Matrix4.translationValues(_backSwipeOffset, 0, 0),
          child: SafeArea(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      18,
                      12,
                      20,
                      0,
                    ),
                    child: AppHeader(
                      title: localization.translate('booksHeaderTitle'),
                      showBackButton: widget.onBack != null,
                      onBack: widget.onBack,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      10,
                      20,
                      0,
                    ),
                    child: Text(
                      localization.translate('booksSubtitle'),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      12,
                      20,
                      0,
                    ),
                    child: AppSearchField(
                      controller: _searchController,
                      hint: localization.translate('searchBooks'),
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
                  child: SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 6);
                      },
                      itemBuilder: (context, index) {
                        final category = _categories[index];

                        return AppCategoryChip(
                          title: localization.translate(
                            category.localizationKey,
                          ),
                          selected: _selectedCategoryId == category.id,
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<BooksCubit, BooksState>(
                  builder: (context, state) {
                    if (state is BooksInitial || state is BooksLoading) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    if (state is BooksError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStateMessage(
                          icon: Icons.error_outline_rounded,
                          title: localization.translate('booksLoadError'),
                          subtitle: state.message,
                          retryLabel: localization.translate('tryAgain'),
                          onRetry: () {
                            context.read<BooksCubit>().getBooks();
                          },
                        ),
                      );
                    }

                    if (state is BooksEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStateMessage(
                          icon: Icons.menu_book_outlined,
                          title: localization.translate('noBooksYet'),
                          subtitle: localization.translate(
                            'booksEmptySubtitle',
                          ),
                        ),
                      );
                    }

                    if (state is BooksSuccess) {
                      final filteredBooks = _filterBooks(state.books);
                      final lastBook = _findLastBook(state.books);

                      if (filteredBooks.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppStateMessage(
                            icon: Icons.search_off_rounded,
                            title: localization.translate('noBooksYet'),
                            subtitle: localization.translate('searchBooks'),
                          ),
                        );
                      }

                      final isArabic =
                          Localizations.localeOf(context).languageCode == 'ar';

                      final continueTitle = lastBook == null
                          ? ''
                          : isArabic
                          ? lastBook.titleArabic
                          : lastBook.titleEnglish.trim().isNotEmpty
                          ? lastBook.titleEnglish
                          : lastBook.titleArabic;

                      return SliverMainAxisGroup(
                        slivers: [
                          if (lastBook != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  20,
                                  0,
                                  20,
                                  0,
                                ),
                                child: AppContinueCard(
                                  label: localization.translate(
                                    'continueReading',
                                  ),
                                  title: continueTitle,
                                  meta:
                                      '${localization.translate('page')} $_lastPage',
                                  onTap: () {
                                    _continueReading(lastBook);
                                  },
                                  leading: AppMediaThumbnail(
                                    path: lastBook.coverPath,
                                    fallbackIcon: Icons.auto_stories_rounded,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          if (lastBook != null)
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 14),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                20,
                                0,
                                20,
                                8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      localization.translate('allBooks'),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${filteredBooks.length} '
                                      '${localization.translate('booksCount')}',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              20,
                              0,
                              20,
                              30,
                            ),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final book = filteredBooks[index];

                                return BookCard(
                                  book: book,
                                  onTap: () {
                                    _openBookDetails(book);
                                  },
                                );
                              }, childCount: filteredBooks.length),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.02,
                                  ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCategory {
  const _BookCategory({required this.id, required this.localizationKey});

  final String id;
  final String localizationKey;
}
