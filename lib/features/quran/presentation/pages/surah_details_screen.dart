import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/continue_reminder_service.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/audio/quran_audio_cache.dart';
import '../../data/bookmarks/bookmark_local_data_source.dart';
import '../../data/reading/last_reading_local_data_source.dart';
import '../../data/settings/mushaf_settings_local_data_source.dart';
import '../../data/surah/surah_local_data_source.dart';
import '../../domain/entities/surah_entity.dart';
import '../cubit/mushaf_theme_cubit.dart';
import '../cubit/mushaf_theme_state.dart';
import '../widgets/mushaf/mushaf_reader.dart';
import '../widgets/surah_side_menu.dart';

class SurahDetailsScreen extends StatefulWidget {
  const SurahDetailsScreen({
    super.key,
    required this.surah,
    this.initialPageNumber,
  });

  final SurahEntity surah;
  final int? initialPageNumber;

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AudioPlayer _audioPlayer;
  late SurahEntity _currentSurah;

  int _currentPageNumber = 1;

  bool _isLoadingAudio = false;
  bool _audioLoaded = false;

  bool _isBookmarked = false;
  bool _isUpdatingBookmark = false;

  int _bookmarkCheckRequest = 0;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _currentSurah = widget.surah;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final localization = AppLocalizations.of(context);

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();

        return;
      }

      if (!_audioLoaded) {
        setState(() {
          _isLoadingAudio = true;
        });

        final audioFile = await QuranAudioCache.instance.getAudioFile(
          _currentSurah.number,
        );

        if (!mounted) {
          return;
        }

        await _audioPlayer.setFilePath(audioFile.path);

        if (!mounted) {
          return;
        }

        setState(() {
          _audioLoaded = true;
          _isLoadingAudio = false;
        });
      }

      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }

      await _audioPlayer.play();
    } catch (error) {
      debugPrint('QURAN AUDIO ERROR: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingAudio = false;
        _audioLoaded = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('unableToPlayRecitation')),
        ),
      );
    }
  }

  Future<void> _resetAudioForNewSurah() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    _audioLoaded = false;
    _isLoadingAudio = false;
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _loadBookmarkStatus(int pageNumber) async {
    final requestId = ++_bookmarkCheckRequest;

    final bookmarked = await BookmarkLocalDataSource.instance.isBookmarked(
      pageNumber,
    );

    if (!mounted) {
      return;
    }

    if (requestId != _bookmarkCheckRequest) {
      return;
    }

    if (_currentPageNumber != pageNumber) {
      return;
    }

    setState(() {
      _isBookmarked = bookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    if (_isUpdatingBookmark) {
      return;
    }

    final localization = AppLocalizations.of(context);

    final pageNumber = _currentPageNumber;
    final surahNumber = _currentSurah.number;

    setState(() {
      _isUpdatingBookmark = true;
    });

    try {
      final bookmarked = await BookmarkLocalDataSource.instance.toggleBookmark(
        pageNumber: pageNumber,
        surahNumber: surahNumber,
      );

      if (!mounted) {
        return;
      }

      if (_currentPageNumber == pageNumber) {
        setState(() {
          _isBookmarked = bookmarked;
        });
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text(
            bookmarked
                ? localization.translate('bookmarkSaved')
                : localization.translate('bookmarkRemoved'),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.translate('bookmarkError'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingBookmark = false;
        });
      }
    }
  }

  Future<void> _updatePageNumber(int pageNumber) async {
    if (!mounted) {
      return;
    }

    final newSurahNumber = _resolveSurahNumberForPage(pageNumber);

    final pageChanged = _currentPageNumber != pageNumber;

    final surahChanged =
        newSurahNumber != null && newSurahNumber != _currentSurah.number;

    if (surahChanged) {
      await _resetAudioForNewSurah();

      if (!mounted) {
        return;
      }
    }

    if (pageChanged || surahChanged) {
      setState(() {
        _currentPageNumber = pageNumber;

        if (surahChanged) {
          _currentSurah = _buildLocalSurahEntity(newSurahNumber);
        }

        _isBookmarked = false;
      });
    }

    await _loadBookmarkStatus(pageNumber);

    if (!mounted) {
      return;
    }

    await LastReadingLocalDataSource.instance.saveLastReading(
      pageNumber: pageNumber,
      surahNumber: _currentSurah.number,
    );

    if (!mounted) {
      return;
    }

    await _updateQuranReminder(
      pageNumber: pageNumber,
      surahNumber: _currentSurah.number,
    );
  }

  Future<void> _updateQuranReminder({
    required int pageNumber,
    required int surahNumber,
  }) async {
    if (!mounted) {
      return;
    }

    if (pageNumber >= 604) {
      await ContinueReminderService.instance.cancelQuranReminder();

      return;
    }

    final localization = AppLocalizations.of(context);

    await ContinueReminderService.instance.scheduleQuranReminder(
      pageNumber: pageNumber,
      surahNumber: surahNumber,
      title: localization.translate('continueQuranReminderTitle'),
      body: localization.translate('continueQuranReminderBody'),
    );
  }

  int? _resolveSurahNumberForPage(int pageNumber) {
    final surahs = SurahLocalDataSource.instance.getAllSurahs();

    int? resolvedSurahNumber;

    for (final surah in surahs) {
      if (surah.startPage <= pageNumber) {
        resolvedSurahNumber = surah.number;
      } else {
        break;
      }
    }

    return resolvedSurahNumber;
  }

  SurahEntity _buildLocalSurahEntity(int surahNumber) {
    final localInfo = SurahLocalDataSource.instance.getSurah(surahNumber);

    return SurahEntity(
      id: 'local_surah_$surahNumber',
      number: localInfo.number,
      nameArabic: localInfo.arabicName,
      nameEnglish: localInfo.englishName,
      revelationType: localInfo.revelationType,
      numberOfAyahs: localInfo.ayahCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final displayedPageNumber = localizedNumber(
      value: _currentPageNumber,
      isArabic: isArabic,
    );

    return BlocBuilder<MushafThemeCubit, MushafThemeState>(
      builder: (context, mushafThemeState) {
        final isNightMode =
            mushafThemeState.readingMode == MushafReadingMode.night;

        final backgroundColor = isNightMode
            ? const Color(0xFF0D1411)
            : const Color(0xFFF7F1E7);

        final foregroundColor = isNightMode
            ? const Color(0xFFB8D2C5)
            : const Color(0xFF1D5946);

        final bookmarkColor = const Color(0xFFD5B26B);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundColor,
          endDrawer: SurahSideMenu(
            surah: _currentSurah,
            audioPlayer: _audioPlayer,
            isLoadingAudio: _isLoadingAudio,
            onToggleAudio: _toggleAudio,
          ),
          body: ColoredBox(
            color: backgroundColor,
            child: SafeArea(
              child: Column(
                children: [
                  _MushafHeader(
                    pageLabel: localization.translate('page'),
                    displayedPageNumber: displayedPageNumber,
                    isBookmarked: _isBookmarked,
                    isUpdatingBookmark: _isUpdatingBookmark,
                    addBookmarkTooltip: localization.translate('addBookmark'),
                    removeBookmarkTooltip: localization.translate(
                      'removeBookmark',
                    ),
                    foregroundColor: foregroundColor,
                    bookmarkColor: bookmarkColor,
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onBookmark: _toggleBookmark,
                    onMenu: _openMenu,
                  ),
                  Expanded(
                    child: MushafReader(
                      surahNumber: widget.surah.number,
                      initialPageNumber: widget.initialPageNumber,
                      onInitialPageResolved: _updatePageNumber,
                      onPageChanged: _updatePageNumber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MushafHeader extends StatelessWidget {
  const _MushafHeader({
    required this.pageLabel,
    required this.displayedPageNumber,
    required this.isBookmarked,
    required this.isUpdatingBookmark,
    required this.addBookmarkTooltip,
    required this.removeBookmarkTooltip,
    required this.foregroundColor,
    required this.bookmarkColor,
    required this.onBack,
    required this.onBookmark,
    required this.onMenu,
  });

  final String pageLabel;
  final String displayedPageNumber;

  final bool isBookmarked;
  final bool isUpdatingBookmark;

  final String addBookmarkTooltip;
  final String removeBookmarkTooltip;

  final Color foregroundColor;
  final Color bookmarkColor;

  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onBack,
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: 25,
                  color: foregroundColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '$pageLabel $displayedPageNumber',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: isUpdatingBookmark
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onBookmark,
                      tooltip: isBookmarked
                          ? removeBookmarkTooltip
                          : addBookmarkTooltip,
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 27,
                        color: isBookmarked ? bookmarkColor : foregroundColor,
                      ),
                    ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onMenu,
                icon: Icon(
                  Icons.menu_rounded,
                  size: 27,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
