import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/app_continue_card.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../data/datasources/programs_local_data_source.dart';
import '../../data/watching/programs_watching_local_data_source.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/program_entity.dart';
import '../cubit/programs_cubit.dart';
import '../cubit/programs_state.dart';
import '../widgets/program_card.dart';
import 'program_episodes_screen.dart';
import 'video_player_screen.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgramsCubit>()..getPrograms(),
      child: _ProgramsView(onBack: onBack),
    );
  }
}

class _ProgramsView extends StatefulWidget {
  const _ProgramsView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_ProgramsView> createState() => _ProgramsViewState();
}

class _ProgramsViewState extends State<_ProgramsView> {
  final TextEditingController _searchController = TextEditingController();
  double? _backSwipeStartX;
  double _backSwipeOffset = 0;

  String _searchQuery = '';

  EpisodeEntity? _lastEpisode;
  ProgramEntity? _lastProgram;

  int _lastPositionSeconds = 0;

  bool _loadingContinueWatching = true;

  @override
  void initState() {
    super.initState();
    _loadContinueWatching();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContinueWatching() async {
    final record = await ProgramsWatchingLocalDataSource.instance
        .getLastWatching();

    if (record == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lastEpisode = null;
        _lastProgram = null;
        _lastPositionSeconds = 0;
        _loadingContinueWatching = false;
      });

      return;
    }

    final dataSource = ProgramsLocalDataSource.instance;

    final episode = await dataSource.getEpisodeById(
      episodeId: record.episodeId,
    );

    if (episode == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lastEpisode = null;
        _lastProgram = null;
        _lastPositionSeconds = 0;
        _loadingContinueWatching = false;
      });

      return;
    }

    final program = await dataSource.getProgramById(
      programId: episode.programId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _lastEpisode = episode;
      _lastProgram = program;
      _lastPositionSeconds = record.positionSeconds;
      _loadingContinueWatching = false;
    });
  }

  Future<void> _continueWatching() async {
    final episode = _lastEpisode;

    if (episode == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(episode: episode)),
    );

    if (!mounted) {
      return;
    }

    await _loadContinueWatching();
  }

  Future<void> _openProgram(ProgramEntity program) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramEpisodesScreen(program: program),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadContinueWatching();
  }

  String _getEpisodeTitle(BuildContext context, EpisodeEntity episode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return episode.titleArabic;
    }

    if (episode.titleEnglish.trim().isNotEmpty) {
      return episode.titleEnglish;
    }

    return episode.titleArabic;
  }

  String? _getProgramTitle(BuildContext context, ProgramEntity? program) {
    if (program == null) {
      return null;
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return program.titleArabic;
    }

    if (program.titleEnglish.trim().isNotEmpty) {
      return program.titleEnglish;
    }

    return program.titleArabic;
  }

  String _getContinueMeta(BuildContext context, AppLocalizations localization) {
    if (_lastPositionSeconds <= 0) {
      return localization.translate('startWatching');
    }

    final position = formatDurationSeconds(_lastPositionSeconds);

    return '${localization.translate('stoppedAt')} $position';
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
                      title: localization.translate('programsTitle'),
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
                      localization.translate('programsSubtitle'),
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
                      hint: localization.translate('searchPrograms'),
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
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                if (!_loadingContinueWatching && _lastEpisode != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        0,
                        20,
                        14,
                      ),
                      child: AppContinueCard(
                        label: localization.translate('continueWatching'),
                        title: _getEpisodeTitle(context, _lastEpisode!),
                        subtitle: _getProgramTitle(context, _lastProgram),
                        meta: _getContinueMeta(context, localization),
                        progress: _lastEpisode!.durationSeconds > 0
                            ? _lastPositionSeconds /
                                  _lastEpisode!.durationSeconds
                            : 0,
                        onTap: _continueWatching,
                        leading: Container(
                          color: colorScheme.surfaceContainer,
                          child: Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 32,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                BlocBuilder<ProgramsCubit, ProgramsState>(
                  builder: (context, state) {
                    if (state is ProgramsInitial || state is ProgramsLoading) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    if (state is ProgramsError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStateMessage(
                          icon: Icons.error_outline_rounded,
                          title: localization.translate('programsLoadError'),
                          subtitle: state.message,
                          retryLabel: localization.translate('tryAgain'),
                          onRetry: () {
                            context.read<ProgramsCubit>().getPrograms();
                          },
                        ),
                      );
                    }

                    if (state is ProgramsEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStateMessage(
                          icon: Icons.ondemand_video_outlined,
                          title: localization.translate('noProgramsYet'),
                          subtitle: localization.translate(
                            'programsEmptySubtitle',
                          ),
                        ),
                      );
                    }

                    if (state is ProgramsSuccess) {
                      final query = _searchQuery.trim().toLowerCase();

                      final programs = state.programs
                          .where((program) {
                            if (query.isEmpty) {
                              return true;
                            }

                            return program.titleArabic.toLowerCase().contains(
                                  query,
                                ) ||
                                program.titleEnglish.toLowerCase().contains(
                                  query,
                                );
                          })
                          .toList(growable: false);

                      if (programs.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppStateMessage(
                            icon: Icons.search_off_rounded,
                            title: localization.translate('noProgramsFound'),
                            subtitle: localization.translate('searchPrograms'),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          0,
                          20,
                          30,
                        ),
                        sliver: SliverList.separated(
                          itemCount: programs.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final program = programs[index];

                            return ProgramCard(
                              program: program,
                              onTap: () {
                                _openProgram(program);
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
        ),
      ),
    );
  }
}
