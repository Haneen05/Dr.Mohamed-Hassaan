import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/books/data/datasources/books_local_data_source.dart';
import '../../features/books/presentation/pages/book_reader_screen.dart';
import '../../features/programs/data/datasources/programs_local_data_source.dart';
import '../../features/programs/presentation/pages/program_episodes_screen.dart';
import '../../features/programs/presentation/pages/video_player_screen.dart';
import '../../features/quran/data/surah/surah_local_data_source.dart';
import '../../features/quran/presentation/pages/surah_details_screen.dart';
import '../../features/sermons/presentation/pages/sermons_screen.dart';
import '../routing/app_navigator.dart';
import 'notification_service.dart';

class NotificationNavigationHandler extends StatefulWidget {
  const NotificationNavigationHandler({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<NotificationNavigationHandler> createState() =>
      _NotificationNavigationHandlerState();
}

class _NotificationNavigationHandlerState
    extends State<NotificationNavigationHandler> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  bool _isOpeningNotification = false;

  Map<String, dynamic>? _pendingData;

  @override
  void initState() {
    super.initState();

    _subscription = NotificationService.instance.notificationTapStream.listen(
      _handleNotification,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data =
      NotificationService.instance.consumePendingNotificationData();

      if (data != null) {
        _handleNotification(data);
      }
    });
  }

  Future<NavigatorState?> _waitForNavigator() async {
    for (var attempt = 0; attempt < 50 && mounted; attempt++) {
      final navigator = AppNavigator.navigator;

      if (navigator != null && navigator.mounted) {
        return navigator;
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return null;
  }

  Future<void> _handleNotification(Map<String, dynamic> data) async {
    if (_isOpeningNotification) {
      _pendingData = data;
      return;
    }

    final type = data['type']?.toString().trim();

    if (type == null || type.isEmpty) {
      return;
    }

    _isOpeningNotification = true;

    try {
      final navigator = await _waitForNavigator();

      if (navigator == null || !mounted) {
        _pendingData = data;
        return;
      }

      switch (type) {
        case 'book':
          await _openBook(data, navigator);
          break;

        case 'program':
          await _openProgram(data, navigator);
          break;

        case 'episode':
          await _openEpisode(data, navigator);
          break;

        case 'sermon':
          await _openSermon(data, navigator);
          break;

        case 'quran':
          await _openQuran(data, navigator);
          break;
      }
    } finally {
      _isOpeningNotification = false;

      final pendingData = _pendingData;
      _pendingData = null;

      if (pendingData != null && mounted) {
        unawaited(_handleNotification(pendingData));
      }
    }
  }

  Future<void> _openBook(
      Map<String, dynamic> data,
      NavigatorState navigator,
      ) async {
    final bookId = _readString(
      data,
      const ['bookId', 'id'],
    );

    if (bookId == null) {
      return;
    }

    final book = await BooksLocalDataSource.instance.getBookById(
      bookId: bookId,
    );

    if (book == null || !mounted) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => BookReaderScreen(
          book: book,
        ),
      ),
    );
  }

  Future<void> _openProgram(
      Map<String, dynamic> data,
      NavigatorState navigator,
      ) async {
    final episodeId = _readString(
      data,
      const ['episodeId', 'id'],
    );

    if (episodeId != null) {
      await _openEpisode(data, navigator);
      return;
    }

    final programId = _readString(
      data,
      const ['programId'],
    );

    if (programId == null) {
      return;
    }

    final program = await ProgramsLocalDataSource.instance.getProgramById(
      programId: programId,
    );

    if (program == null || !mounted) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => ProgramEpisodesScreen(program: program),
      ),
    );
  }

  Future<void> _openEpisode(
      Map<String, dynamic> data,
      NavigatorState navigator,
      ) async {
    final episodeId = _readString(
      data,
      const ['episodeId', 'id'],
    );

    if (episodeId == null) {
      return;
    }

    final episode = await ProgramsLocalDataSource.instance.getEpisodeById(
      episodeId: episodeId,
    );

    if (episode == null || !mounted) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          episode: episode,
        ),
      ),
    );
  }

  Future<void> _openSermon(
      Map<String, dynamic> data,
      NavigatorState navigator,
      ) async {
    if (!mounted) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(builder: (_) => const SermonsScreen()),
    );
  }

  Future<void> _openQuran(
      Map<String, dynamic> data,
      NavigatorState navigator,
      ) async {
    final pageNumber = _readInt(
      data,
      const ['pageNumber', 'page'],
    );

    final surahNumber = _readInt(
      data,
      const ['surahNumber', 'surah'],
    );

    if (pageNumber == null || pageNumber < 1 || pageNumber > 604) {
      return;
    }

    int? resolvedSurahNumber = surahNumber;

    if (resolvedSurahNumber == null ||
        resolvedSurahNumber < 1 ||
        resolvedSurahNumber > 114) {
      resolvedSurahNumber = _resolveSurahNumberForPage(pageNumber);
    }

    if (resolvedSurahNumber == null) {
      return;
    }

    final surah = SurahLocalDataSource.instance.getSurahEntity(
      resolvedSurahNumber,
    );

    if (!mounted) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => SurahDetailsScreen(
          surah: surah,
          initialPageNumber: pageNumber,
        ),
      ),
    );
  }

  int? _resolveSurahNumberForPage(int pageNumber) {
    final surahs = SurahLocalDataSource.instance.getAllSurahs();

    int? surahNumber;

    for (final surah in surahs) {
      if (surah.startPage <= pageNumber) {
        surahNumber = surah.number;
      } else {
        break;
      }
    }

    return surahNumber;
  }

  String? _readString(
      Map<String, dynamic> data,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  int? _readInt(
      Map<String, dynamic> data,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) {
        return value;
      }

      final parsed = int.tryParse(
        value?.toString() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
