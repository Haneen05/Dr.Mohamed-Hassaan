import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../../core/utils/number_formatter.dart';

class MushafReader extends StatefulWidget {
  const MushafReader({
    super.key,
    required this.surahNumber,
    required this.onPageChanged,
    this.onInitialPageResolved,
    this.initialPageNumber,
  });

  final int surahNumber;
  final int? initialPageNumber;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onInitialPageResolved;

  @override
  State<MushafReader> createState() => _MushafReaderState();
}

class _MushafReaderState extends State<MushafReader> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _ayahKeys;
  late final int _ayahCount;
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _ayahCount = getVerseCount(widget.surahNumber);
    _ayahKeys = List.generate(_ayahCount, (_) => GlobalKey());
    _scrollController.addListener(_reportVisiblePage);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToStartPage());
  }

  void _jumpToStartPage() {
    if (!mounted) return;
    final requestedPage =
        widget.initialPageNumber ?? getPageNumber(widget.surahNumber, 1);
    final ayah = List.generate(_ayahCount, (i) => i + 1).firstWhere(
      (number) => getPageNumber(widget.surahNumber, number) >= requestedPage,
      orElse: () => 1,
    );
    final targetContext = _ayahKeys[ayah - 1].currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.12,
        duration: Duration.zero,
      );
    }
    _reportPage(ayah);
    widget.onInitialPageResolved?.call(getPageNumber(widget.surahNumber, ayah));
  }

  void _reportVisiblePage() {
    final viewportTop = _scrollController.position.hasContentDimensions
        ? 0.0
        : double.infinity;
    var bestAyah = 1;
    var bestTop = double.infinity;
    for (var i = 0; i < _ayahKeys.length; i++) {
      final context = _ayahKeys[i].currentContext;
      final render = context?.findRenderObject();
      if (render is! RenderBox || !render.hasSize) continue;
      final top = render.localToGlobal(Offset.zero).dy;
      if (top <= viewportTop + 180 && top < bestTop) {
        bestTop = top;
        bestAyah = i + 1;
      }
    }
    _reportPage(bestAyah);
  }

  void _reportPage(int ayahNumber) {
    final page = getPageNumber(widget.surahNumber, ayahNumber);
    if (page == _lastReportedPage) return;
    _lastReportedPage = page;
    widget.onPageChanged(page);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_reportVisiblePage)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 40),
        itemCount: _ayahCount,
        itemBuilder: (context, index) {
          final ayahNumber = index + 1;
          return Padding(
            key: _ayahKeys[index],
            padding: const EdgeInsets.only(bottom: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      getVerse(widget.surahNumber, ayahNumber),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 23,
                        height: 1.9,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          localizedNumber(
                            value: ayahNumber,
                            isArabic: isArabic,
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
