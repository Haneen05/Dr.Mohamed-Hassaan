import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/continue_reminder_service.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/reading/books_reading_local_data_source.dart';
import '../../domain/entities/book_entity.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key, required this.book});

  final BookEntity book;

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late final PdfViewerController _controller;

  int _currentPage = 1;
  int _pageCount = 0;
  int _initialPage = 1;

  bool _readerReady = false;
  bool _loadingLastPage = true;

  @override
  void initState() {
    super.initState();

    _controller = PdfViewerController();

    _loadLastReading();
  }

  Future<void> _loadLastReading() async {
    final savedPage = await BooksReadingLocalDataSource.instance.getBookPage(
      bookId: widget.book.id,
    );

    await BooksReadingLocalDataSource.instance.saveReading(
      bookId: widget.book.id,
      pageNumber: savedPage,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _initialPage = savedPage;
      _currentPage = savedPage;
      _loadingLastPage = false;
    });
  }

  Future<void> _saveLastReading(int pageNumber) async {
    await BooksReadingLocalDataSource.instance.saveReading(
      bookId: widget.book.id,
      pageNumber: pageNumber,
    );

    if (!mounted) {
      return;
    }

    await _updateBookReminder(pageNumber);
  }

  Future<void> _updateBookReminder(int pageNumber) async {
    final localization = AppLocalizations.of(context);

    if (_pageCount > 0 && pageNumber >= _pageCount) {
      await ContinueReminderService.instance.cancelBookReminder();

      return;
    }

    await ContinueReminderService.instance.scheduleBookReminder(
      bookId: widget.book.id,
      pageNumber: pageNumber,
      title: localization.translate('continueBookReminderTitle'),
      body: localization.translate('continueBookReminderBody'),
    );
  }

  void _onPageChanged(int? pageNumber) {
    if (pageNumber == null) {
      return;
    }

    if (pageNumber == _currentPage) {
      return;
    }

    setState(() {
      _currentPage = pageNumber;
    });

    _saveLastReading(pageNumber);
  }

  Future<void> _previousPage() async {
    if (!_readerReady) {
      return;
    }

    if (_currentPage <= 1) {
      return;
    }

    await _controller.goToPage(
      pageNumber: _currentPage - 1,
      anchor: PdfPageAnchor.top,
    );
  }

  Future<void> _nextPage() async {
    if (!_readerReady) {
      return;
    }

    if (_pageCount > 0 && _currentPage >= _pageCount) {
      return;
    }

    await _controller.goToPage(
      pageNumber: _currentPage + 1,
      anchor: PdfPageAnchor.top,
    );
  }

  Future<void> _showPagePicker() async {
    if (!_readerReady || _pageCount <= 0) {
      return;
    }

    final localization = AppLocalizations.of(context);
    final pageController = TextEditingController(text: '$_currentPage');

    final selectedPage = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            localization.translate('goToPage'),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: pageController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            cursorColor: colorScheme.primary,
            onSubmitted: (value) {
              final page = int.tryParse(value.trim());

              if (page == null || page < 1 || page > _pageCount) {
                return;
              }

              Navigator.of(dialogContext).pop(page);
            },
            decoration: InputDecoration(
              hintText: '1 - $_pageCount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(localization.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final page = int.tryParse(pageController.text.trim());

                if (page == null || page < 1 || page > _pageCount) {
                  return;
                }

                Navigator.of(dialogContext).pop(page);
              },
              child: Text(localization.translate('go')),
            ),
          ],
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));

    pageController.dispose();

    if (!mounted || selectedPage == null) {
      return;
    }

    await _controller.goToPage(
      pageNumber: selectedPage,
      anchor: PdfPageAnchor.top,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = selectedPage;
    });

    await _saveLastReading(selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? widget.book.titleArabic
        : widget.book.titleEnglish.trim().isNotEmpty
        ? widget.book.titleEnglish
        : widget.book.titleArabic;

    final pdfPath = widget.book.pdfPath.trim();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 0),
              child: AppHeader(
                title: title,
                showBackButton: true,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _loadingLastPage
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : pdfPath.isEmpty
                  ? AppStateMessage(
                      icon: Icons.menu_book_outlined,
                      title: localization.translate('bookUnavailable'),
                      subtitle: '',
                    )
                  : PdfViewer.asset(
                      pdfPath,
                      controller: _controller,
                      initialPageNumber: _initialPage,
                      params: PdfViewerParams(
                        backgroundColor: colorScheme.surface,
                        margin: 10,
                        onViewerReady: (document, controller) {
                          if (!mounted) {
                            return;
                          }

                          final current = controller.pageNumber ?? _initialPage;

                          setState(() {
                            _readerReady = true;
                            _pageCount = controller.pageCount;
                            _currentPage = current;
                          });

                          _saveLastReading(current);
                        },
                        onPageChanged: (pageNumber) {
                          _onPageChanged(pageNumber);
                        },
                      ),
                    ),
            ),
            if (!_loadingLastPage && pdfPath.isNotEmpty)
              _ReaderControls(
                currentPage: _currentPage,
                pageCount: _pageCount,
                onPrevious: _previousPage,
                onNext: _nextPage,
                onPageTap: _showPagePicker,
              ),
          ],
        ),
      ),
    );
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onPageTap,
  });

  final int currentPage;
  final int pageCount;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPageTap;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(18, 6, 18, 10),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: currentPage > 1 ? onPrevious : null,
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                size: 25,
              ),
              color: colorScheme.primary,
              disabledColor: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onPageTap,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  pageCount > 0
                      ? '${localization.translate('page')} '
                            '$currentPage / $pageCount'
                      : '${localization.translate('page')} '
                            '$currentPage',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: pageCount == 0 || currentPage < pageCount
                  ? onNext
                  : null,
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 25,
              ),
              color: colorScheme.primary,
              disabledColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
