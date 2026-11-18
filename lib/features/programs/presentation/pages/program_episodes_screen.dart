import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_media_thumbnail.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/program_entity.dart';
import '../cubit/program_episodes_cubit.dart';
import '../cubit/program_episodes_state.dart';
import 'video_player_screen.dart';

class ProgramEpisodesScreen extends StatelessWidget {
  const ProgramEpisodesScreen({super.key, required this.program});

  final ProgramEntity program;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProgramEpisodesCubit>()..getEpisodes(programId: program.id),
      child: _ProgramEpisodesView(program: program),
    );
  }
}

class _ProgramEpisodesView extends StatelessWidget {
  const _ProgramEpisodesView({required this.program});

  final ProgramEntity program;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? program.titleArabic
        : program.titleEnglish.trim().isNotEmpty
        ? program.titleEnglish
        : program.titleArabic;

    final description = isArabic
        ? program.descriptionArabic
        : program.descriptionEnglish.trim().isNotEmpty
        ? program.descriptionEnglish
        : program.descriptionArabic;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 0),
                child: AppHeader(
                  title: title,
                  showBackButton: true,
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.ondemand_video_rounded,
                          color: colorScheme.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            if (description.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 9.5,
                                  height: 1.5,
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.72,
                                  ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                child: Text(
                  localization.translate('programEpisodes'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            BlocBuilder<ProgramEpisodesCubit, ProgramEpisodesState>(
              builder: (context, state) {
                if (state is ProgramEpisodesInitial ||
                    state is ProgramEpisodesLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (state is ProgramEpisodesError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.error_outline_rounded,
                      title: localization.translate('episodesLoadError'),
                      subtitle: state.message,
                      retryLabel: localization.translate('tryAgain'),
                      onRetry: () {
                        context.read<ProgramEpisodesCubit>().getEpisodes(
                          programId: program.id,
                        );
                      },
                    ),
                  );
                }

                if (state is ProgramEpisodesEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.video_library_outlined,
                      title: localization.translate('noEpisodesYet'),
                      subtitle: localization.translate('episodesEmptySubtitle'),
                    ),
                  );
                }

                if (state is ProgramEpisodesSuccess) {
                  return SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 30),
                    sliver: SliverList.separated(
                      itemCount: state.episodes.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final episode = state.episodes[index];

                        return _EpisodeCard(
                          episode: episode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VideoPlayerScreen(episode: episode),
                              ),
                            );
                          },
                        );
                      },
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

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.onTap});

  final EpisodeEntity episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? episode.titleArabic
        : episode.titleEnglish.trim().isNotEmpty
        ? episode.titleEnglish
        : episode.titleArabic;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 69,
                child: AppMediaThumbnail(
                  path: episode.thumbnailPath,
                  fallbackIcon: Icons.ondemand_video_rounded,
                  borderRadius: 12,
                  overlayAlpha: 0.12,
                  showPlayButton: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${localization.translate('episode')} '
                      '${episode.episodeNumber}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (episode.durationSeconds > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        formatDurationSeconds(episode.durationSeconds),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
