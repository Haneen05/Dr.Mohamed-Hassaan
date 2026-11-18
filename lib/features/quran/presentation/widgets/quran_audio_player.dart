import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/surah_entity.dart';

class QuranAudioPlayer extends StatelessWidget {
  const QuranAudioPlayer({
    super.key,
    required this.audioPlayer,
    required this.surah,
    required this.isLoadingAudio,
    required this.onToggleAudio,
    required this.listenText,
  });

  final AudioPlayer audioPlayer;
  final SurahEntity surah;
  final bool isLoadingAudio;
  final Future<void> Function() onToggleAudio;
  final String listenText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.headphones_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                surah.nameArabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;

                final playing = state?.playing ?? false;
                final processing = state?.processingState;

                final busy =
                    isLoadingAudio ||
                    processing == ProcessingState.loading ||
                    processing == ProcessingState.buffering;

                return Material(
                  color: colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: busy ? null : onToggleAudio,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: busy
                          ? Padding(
                              padding: const EdgeInsets.all(13),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: colorScheme.onPrimary,
                              size: 28,
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                listenText,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<Duration>(
          stream: audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = audioPlayer.duration ?? Duration.zero;

            final double max = duration.inMilliseconds > 0
                ? duration.inMilliseconds.toDouble()
                : 1.0;

            final double value = position.inMilliseconds
                .toDouble()
                .clamp(0.0, max)
                .toDouble();

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 4,
                    ),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: max,
                    value: value,
                    activeColor: colorScheme.primary,
                    inactiveColor: colorScheme.surfaceContainerHighest,
                    onChanged: duration.inMilliseconds <= 0
                        ? null
                        : (newValue) {
                            audioPlayer.seek(
                              Duration(milliseconds: newValue.round()),
                            );
                          },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(position),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 8.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatDuration(duration),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 8.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
