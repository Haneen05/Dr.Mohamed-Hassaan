import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/notification_local_data_source.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/notifications/notifications_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/data/datasources/books_local_data_source.dart';
import '../../../books/domain/entities/book_entity.dart';
import '../../../books/presentation/pages/book_details_screen.dart';
import '../../../programs/data/datasources/programs_local_data_source.dart';
import '../../../programs/domain/entities/program_entity.dart';
import '../../../programs/presentation/pages/program_episodes_screen.dart';
import '../../../sermons/data/datasources/sermons_local_data_source.dart';
import '../../../sermons/domain/entities/sermon_entity.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../books/presentation/pages/books_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../programs/presentation/pages/programs_screen.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../quran/presentation/pages/quran_screen.dart';
import '../../../sermons/presentation/pages/sermons_screen.dart';
import 'search_results_screen.dart';
import '../widgets/home_side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _openSideMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _goToBooks() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _goToPrograms() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void _changeBottomNavigationPage(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      drawer: const HomeSideMenu(),
      drawerEnableOpenDragGesture: false,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeContent(
            onMenuTap: _openSideMenu,
            onBooksTap: _goToBooks,
            onProgramsTap: _goToPrograms,
          ),
          BooksScreen(onBack: _goToHome),
          ProgramsScreen(onBack: _goToHome),
          ProfileScreen(onBack: _goToHome),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onDestinationSelected: _changeBottomNavigationPage,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({
    required this.onMenuTap,
    required this.onBooksTap,
    required this.onProgramsTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onBooksTap;
  final VoidCallback onProgramsTap;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  late final ProfileCubit _profileCubit;

  StreamSubscription<void>? _notificationSubscription;

  int _unreadNotificationsCount = 0;
  _LatestEntry? _latestEntry;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _profileCubit = sl<ProfileCubit>()..getProfile();

    _loadUnreadNotificationsCount();
    _loadLatestEntry();

    _notificationSubscription = NotificationService
        .instance
        .notificationChangedStream
        .listen((_) {
          _loadUnreadNotificationsCount();
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadNotificationsCount();
    }
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final count = await NotificationLocalDataSource.instance.getUnreadCount();

    if (!mounted) {
      return;
    }

    setState(() {
      _unreadNotificationsCount = count;
    });
  }

  Future<void> _loadLatestEntry() async {
    final results = await Future.wait([
      BooksLocalDataSource.instance.getBooks(),
      ProgramsLocalDataSource.instance.getPrograms(),
      SermonsLocalDataSource.instance.getSermons(),
    ]);
    final entries = <_LatestEntry>[
      ...(results[0] as List<BookEntity>)
          .where((item) => item.isAvailable)
          .map((item) => _LatestEntry(item.sortOrder, item)),
      ...(results[1] as List<ProgramEntity>)
          .where((item) => item.isAvailable)
          .map((item) => _LatestEntry(item.sortOrder, item)),
      ...(results[2] as List<SermonEntity>)
          .where((item) => item.isAvailable)
          .map((item) => _LatestEntry(item.sortOrder, item)),
    ];
    entries.sort((a, b) => b.order.compareTo(a.order));
    if (mounted) setState(() => _latestEntry = entries.firstOrNull);
  }

  void _openLatestEntry(_LatestEntry entry) {
    final page = switch (entry.content) {
      BookEntity book => BookDetailsScreen(book: book),
      ProgramEntity program => ProgramEpisodesScreen(program: program),
      SermonEntity _ => const SermonsScreen(),
      _ => null,
    };
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  void _openQuran() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuranScreen()),
    );
  }

  void _openSermons() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SermonsScreen()),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );

    await _loadUnreadNotificationsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _notificationSubscription?.cancel();

    _profileCubit.close();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 0),
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  bloc: _profileCubit,
                  builder: (context, profileState) {
                    final displayName = _displayName(
                      profileState,
                      localization,
                    );

                    return AppHeader(
                      title: displayName,
                      subtitle: localization.translate('assalamuAlaikum'),
                      leadingIcon: Icons.menu_rounded,
                      onLeadingTap: widget.onMenuTap,
                      trailingIcon: Icons.notifications_none_rounded,
                      onTrailingTap: _openNotifications,
                      trailingBadgeCount: _unreadNotificationsCount,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 0),
                child: AppSearchField(
                  controller: _searchController,
                  hint: localization.translate('searchApp'),
                  readOnly: true,
                  onTap: _openSearch,
                  onClear: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 16),
                child: Text(
                  localization.translate('mainSections'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate([
                  _HomeCategoryTile(
                    icon: Icons.auto_stories_rounded,
                    title: localization.translate('quran'),
                    subtitle: localization.translate('quranRecitations'),
                    accent: AppColors.primaryDark,
                    onTap: _openQuran,
                  ),
                  _HomeCategoryTile(
                    icon: Icons.ondemand_video_rounded,
                    title: localization.translate('programsTitle'),
                    subtitle: localization.translate('programsHomeSubtitle'),
                    accent: AppColors.primary,
                    onTap: widget.onProgramsTap,
                  ),
                  _HomeCategoryTile(
                    icon: Icons.menu_book_rounded,
                    title: localization.translate('books'),
                    subtitle: localization.translate('bookCollection'),
                    accent: AppColors.gold,
                    onTap: widget.onBooksTap,
                  ),
                  _HomeCategoryTile(
                    icon: Icons.headphones_rounded,
                    title: localization.translate('audioLessons'),
                    subtitle: localization.translate('audioLectures'),
                    accent: AppColors.primary,
                    onTap: () => _showComingSoon(
                      localization.translate('audioLessonsComingSoon'),
                    ),
                  ),
                  _HomeCategoryTile(
                    icon: Icons.campaign_rounded,
                    title: localization.translate('sermonsTitle'),
                    subtitle: localization.translate('sermonsSubtitle'),
                    accent: AppColors.gold,
                    onTap: _openSermons,
                  ),
                  _HomeCategoryTile(
                    icon: Icons.format_quote_rounded,
                    title: localization.translate('fatwas'),
                    subtitle: localization.translate('fatwaCollection'),
                    accent: AppColors.primaryDark,
                    onTap: () => _showComingSoon(
                      localization.translate('fatwasComingSoon'),
                    ),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.translate('latestContent'),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SearchResultsScreen(showAll: true),
                        ),
                      ),
                      child: Text(localization.translate('allContent')),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_latestEntry case final entry?)
                    _LatestContentCard(
                      icon: entry.content is BookEntity
                          ? Icons.menu_book_rounded
                          : entry.content is SermonEntity
                          ? Icons.campaign_rounded
                          : Icons.ondemand_video_rounded,
                      title: _latestEntryTitle(entry, localization),
                      category: localization.translate(
                        entry.content is BookEntity
                            ? 'books'
                            : entry.content is SermonEntity
                            ? 'sermonsTitle'
                            : 'programsTitle',
                      ),
                      meta: localization.translate('latestContent'),
                      onTap: () => _openLatestEntry(entry),
                    )
                  else
                    Text(localization.translate('noContentYet')),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(ProfileState state, AppLocalizations localization) {
    if (state is ProfileSuccess) {
      final name = state.profile.name.trim();

      if (name.isNotEmpty) {
        return name;
      }

      final email = state.profile.email.trim();
      final atIndex = email.indexOf('@');

      if (atIndex > 0) {
        return email.substring(0, atIndex);
      }
    }

    return localization.translate('welcomeBack');
  }

  String _latestEntryTitle(_LatestEntry entry, AppLocalizations localization) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return switch (entry.content) {
      BookEntity book => isArabic ? book.titleArabic : book.titleEnglish,
      ProgramEntity program =>
        isArabic ? program.titleArabic : program.titleEnglish,
      SermonEntity sermon =>
        isArabic ? sermon.titleArabic : sermon.titleEnglish,
      _ => localization.translate('noContentYet'),
    };
  }
}

class _LatestEntry {
  const _LatestEntry(this.order, this.content);
  final int order;
  final Object content;
}

class _HomeCategoryTile extends StatelessWidget {
  const _HomeCategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: accent, size: 27),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8.5,
                  height: 1.35,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestContentCard extends StatelessWidget {
  const _LatestContentCard({
    required this.icon,
    required this.title,
    required this.category,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String category;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: colors.primary, size: 27),
              ),
              const SizedBox(width: 13),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                textDirection == TextDirection.rtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 13,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
