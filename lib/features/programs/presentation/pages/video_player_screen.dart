import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/continue_reminder_service.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../data/watching/programs_watching_local_data_source.dart';
import '../../domain/entities/episode_entity.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.episode});

  final EpisodeEntity episode;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;

  bool _initialized = false;
  bool _hasError = false;

  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.episode.videoPath);

    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(1.0);

      final savedSeconds = await ProgramsWatchingLocalDataSource.instance
          .getEpisodePosition(episodeId: widget.episode.id);

      final durationSeconds = _controller.value.duration.inSeconds;

      if (savedSeconds > 0 && savedSeconds < durationSeconds - 5) {
        await _controller.seekTo(Duration(seconds: savedSeconds));
      }

      await ProgramsWatchingLocalDataSource.instance.saveWatching(
        episodeId: widget.episode.id,
        positionSeconds: savedSeconds,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _initialized = true;
        _hasError = false;
      });

      await _updateProgramReminder(
        positionSeconds: savedSeconds,
        durationSeconds: durationSeconds,
      );

      _startAutoSave();
    } catch (error) {
      debugPrint('VIDEO INITIALIZE ERROR: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    }
  }

  void _startAutoSave() {
    _saveTimer?.cancel();

    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveProgressOnly();
    });
  }

  Future<void> _saveProgressOnly() async {
    if (!_initialized || _controller.value.hasError) {
      return;
    }

    final currentSeconds = _controller.value.position.inSeconds;
    final durationSeconds = _controller.value.duration.inSeconds;

    var positionToSave = currentSeconds;

    if (durationSeconds > 0 && currentSeconds >= durationSeconds - 5) {
      positionToSave = 0;
    }

    await ProgramsWatchingLocalDataSource.instance.saveWatching(
      episodeId: widget.episode.id,
      positionSeconds: positionToSave,
    );
  }

  Future<void> _saveCurrentPosition() async {
    if (!_initialized || _controller.value.hasError) {
      return;
    }

    final currentSeconds = _controller.value.position.inSeconds;
    final durationSeconds = _controller.value.duration.inSeconds;

    var positionToSave = currentSeconds;

    if (durationSeconds > 0 && currentSeconds >= durationSeconds - 5) {
      positionToSave = 0;
    }

    await ProgramsWatchingLocalDataSource.instance.saveWatching(
      episodeId: widget.episode.id,
      positionSeconds: positionToSave,
    );

    if (!mounted) {
      return;
    }

    await _updateProgramReminder(
      positionSeconds: positionToSave,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> _updateProgramReminder({
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    if (!mounted) {
      return;
    }

    if (positionSeconds <= 0 ||
        durationSeconds <= 0 ||
        positionSeconds >= durationSeconds - 5) {
      await ContinueReminderService.instance.cancelProgramReminder();

      return;
    }

    final localization = AppLocalizations.of(context);

    await ContinueReminderService.instance.scheduleProgramReminder(
      episodeId: widget.episode.id,
      positionSeconds: positionSeconds,
      title: localization.translate('continueProgramReminderTitle'),
      body: localization.translate('continueProgramReminderBody'),
    );
  }

  Future<void> _goBack() async {
    _saveTimer?.cancel();

    if (_initialized && _controller.value.isPlaying) {
      await _controller.pause();
    }

    await _saveCurrentPosition();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _togglePlayPause() async {
    if (!_initialized) {
      return;
    }

    if (_controller.value.isPlaying) {
      await _controller.pause();

      await _saveCurrentPosition();
    } else {
      final duration = _controller.value.duration;
      final position = _controller.value.position;

      if (duration.inSeconds > 0 &&
          position >= duration - const Duration(seconds: 2)) {
        await _controller.seekTo(Duration.zero);
      }

      await _controller.setVolume(1.0);
      await _controller.play();
    }

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _seekBackward() async {
    if (!_initialized) {
      return;
    }

    final current = _controller.value.position;
    final target = current - const Duration(seconds: 10);

    await _controller.seekTo(target < Duration.zero ? Duration.zero : target);

    await _saveCurrentPosition();
  }

  Future<void> _seekForward() async {
    if (!_initialized) {
      return;
    }

    final current = _controller.value.position;
    final duration = _controller.value.duration;

    final target = current + const Duration(seconds: 10);

    await _controller.seekTo(target > duration ? duration : target);

    await _saveCurrentPosition();
  }

  Future<void> _openFullScreen() async {
    if (!_initialized) {
      return;
    }

    await _saveCurrentPosition();

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPlayer(controller: _controller),
      ),
    );

    if (!mounted) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 150));

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await _saveCurrentPosition();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _saveTimer?.cancel();

    _controller.pause();
    _controller.dispose();

    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? widget.episode.titleArabic
        : widget.episode.titleEnglish.trim().isNotEmpty
        ? widget.episode.titleEnglish
        : widget.episode.titleArabic;

    final description = isArabic
        ? widget.episode.descriptionArabic
        : widget.episode.descriptionEnglish.trim().isNotEmpty
        ? widget.episode.descriptionEnglish
        : widget.episode.descriptionArabic;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        await _goBack();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _goBack,
                        icon: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.arrow_back_ios_new_rounded,
                          size: 19,
                          color: colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _openFullScreen,
                  child: AspectRatio(
                    aspectRatio:
                        _initialized && _controller.value.aspectRatio > 0
                        ? _controller.value.aspectRatio
                        : 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: _buildVideoArea(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 0),
                  child: _initialized
                      ? ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: colorScheme.primary,
                                    bufferedColor: colorScheme.primaryContainer,
                                    backgroundColor: colorScheme.outlineVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      formatDuration(value.position),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9.5,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatDuration(value.duration),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9.5,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _seekBackward,
                                      icon: Icon(
                                        Icons.replay_10_rounded,
                                        size: 30,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: _togglePlayPause,
                                        icon: Icon(
                                          value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 34,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    IconButton(
                                      onPressed: _seekForward,
                                      icon: Icon(
                                        Icons.forward_10_rounded,
                                        size: 30,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextButton.icon(
                                  onPressed: _openFullScreen,
                                  icon: const Icon(
                                    Icons.fullscreen_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    localization.translate('fullScreen'),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : const SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 24, 18, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            height: 1.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline_rounded, size: 42, color: Colors.white),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return VideoPlayer(_controller);
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  const _FullScreenVideoPlayer({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isExiting = false;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();

    _enterFullScreen();
  }

  Future<void> _enterFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullScreen() async {
    if (_isExiting) {
      return;
    }

    _isExiting = true;

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      final duration = _controller.value.duration;
      final position = _controller.value.position;

      if (duration.inSeconds > 0 &&
          position >= duration - const Duration(seconds: 2)) {
        await _controller.seekTo(Duration.zero);
      }

      await _controller.setVolume(1.0);
      await _controller.play();
    }

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _seekBackward() async {
    final target = _controller.value.position - const Duration(seconds: 10);

    await _controller.seekTo(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> _seekForward() async {
    final target = _controller.value.position + const Duration(seconds: 10);

    final duration = _controller.value.duration;

    await _controller.seekTo(target > duration ? duration : target);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        await _exitFullScreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.22),
                        child: SafeArea(
                          child: Stack(
                            children: [
                              PositionedDirectional(
                                top: 8,
                                start: 8,
                                child: IconButton(
                                  onPressed: _exitFullScreen,
                                  icon: const Icon(
                                    Icons.close_fullscreen_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _seekBackward,
                                      icon: const Icon(
                                        Icons.replay_10_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                    const SizedBox(width: 28),
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: _togglePlayPause,
                                        icon: Icon(
                                          value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 28),
                                    IconButton(
                                      onPressed: _seekForward,
                                      icon: const Icon(
                                        Icons.forward_10_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 24,
                                right: 24,
                                bottom: 14,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: colorScheme.secondary,
                                        bufferedColor: Colors.white54,
                                        backgroundColor: Colors.white24,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        Text(
                                          formatDuration(value.position),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatDuration(value.duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
