import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_category_chip.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../cubit/sermons_cubit.dart';
import '../cubit/sermons_state.dart';
import '../widgets/sermon_card.dart';

class SermonsScreen extends StatelessWidget {
  const SermonsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SermonsCubit>()..getSermons(),
      child: _SermonsView(onBack: onBack),
    );
  }
}

class _SermonsView extends StatefulWidget {
  const _SermonsView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_SermonsView> createState() => _SermonsViewState();
}

class _SermonsViewState extends State<_SermonsView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategoryId = 'all';

  static const List<_SermonCategory> _categories = [
    _SermonCategory(id: 'all', localizationKey: 'allCategory'),
    _SermonCategory(id: 'aqeedah', localizationKey: 'aqeedahCategory'),
    _SermonCategory(
      id: 'heart_softeners',
      localizationKey: 'heartSoftenersCategory',
    ),
    _SermonCategory(id: 'repentance', localizationKey: 'repentanceCategory'),
    _SermonCategory(id: 'fitan', localizationKey: 'fitanCategory'),
    _SermonCategory(
      id: 'family_society',
      localizationKey: 'familySocietyCategory',
    ),
    _SermonCategory(id: 'seerah', localizationKey: 'seerahCategory'),
    _SermonCategory(id: 'occasions', localizationKey: 'occasionsCategory'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 20, 0),
                child: AppHeader(
                  title: localization.translate('sermonsTitle'),
                  showBackButton: true,
                  onBack: widget.onBack ?? () => Navigator.pop(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                child: Text(
                  localization.translate('sermonsPageSubtitle'),
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
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                child: AppSearchField(
                  controller: _searchController,
                  hint: localization.translate('searchSermons'),
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
                      title: localization.translate(category.localizationKey),
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
            BlocBuilder<SermonsCubit, SermonsState>(
              builder: (context, state) {
                if (state is SermonsInitial || state is SermonsLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (state is SermonsError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.error_outline_rounded,
                      title: localization.translate('sermonsLoadError'),
                      subtitle: state.message,
                      retryLabel: localization.translate('tryAgain'),
                      onRetry: () {
                        context.read<SermonsCubit>().getSermons();
                      },
                    ),
                  );
                }

                if (state is SermonsEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateMessage(
                      icon: Icons.campaign_outlined,
                      title: localization.translate('noSermonsYet'),
                      subtitle: localization.translate('sermonsEmptySubtitle'),
                    ),
                  );
                }

                if (state is SermonsSuccess) {
                  final query = _searchQuery.trim().toLowerCase();

                  final sermons = state.sermons
                      .where((sermon) {
                        final matchesCategory =
                            _selectedCategoryId == 'all' ||
                            sermon.categoryId == _selectedCategoryId;

                        if (!matchesCategory) {
                          return false;
                        }

                        if (query.isEmpty) {
                          return true;
                        }

                        return sermon.titleArabic.toLowerCase().contains(
                              query,
                            ) ||
                            sermon.titleEnglish.toLowerCase().contains(query);
                      })
                      .toList(growable: false);

                  if (sermons.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppStateMessage(
                        icon: Icons.search_off_rounded,
                        title: localization.translate('noSermonsFound'),
                        subtitle: localization.translate('searchSermons'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 30),
                    sliver: SliverList.separated(
                      itemCount: sermons.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final sermon = sermons[index];

                        return SermonCard(sermon: sermon, onTap: () {});
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

class _SermonCategory {
  const _SermonCategory({required this.id, required this.localizationKey});

  final String id;
  final String localizationKey;
}
