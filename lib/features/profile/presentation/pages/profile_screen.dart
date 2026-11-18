import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getProfile(),
      child: _ProfileView(onBack: onBack),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );

          return;
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.translate(state.localizationKey)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 20, 0),
                child: AppHeader(
                  title: localization.translate('profile'),
                  showBackButton: onBack != null,
                  onBack: onBack,
                ),
              ),
              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileInitial || state is ProfileLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      );
                    }

                    if (state is ProfileError) {
                      return AppStateMessage(
                        icon: Icons.error_outline_rounded,
                        title: localization.translate('profileLoadError'),
                        subtitle: localization.translate(
                          'profileLoadErrorSubtitle',
                        ),
                        retryLabel: localization.translate('tryAgain'),
                        onRetry: () {
                          context.read<ProfileCubit>().getProfile();
                        },
                      );
                    }

                    if (state is ProfileSuccess) {
                      final profile = state.profile;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 46,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (profile.name.trim().isNotEmpty)
                              Text(
                                profile.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            if (profile.email.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                profile.email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 30),
                            _ProfileInfoCard(
                              icon: Icons.person_outline_rounded,
                              label: localization.translate('name'),
                              value: profile.name.trim().isNotEmpty
                                  ? profile.name
                                  : localization.translate(
                                      'profileNameUnavailable',
                                    ),
                            ),
                            const SizedBox(height: 10),
                            _ProfileInfoCard(
                              icon: Icons.email_outlined,
                              label: localization.translate('email'),
                              value: profile.email.trim().isNotEmpty
                                  ? profile.email
                                  : localization.translate(
                                      'profileEmailUnavailable',
                                    ),
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.read<AuthCubit>().logout();
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 19,
                                ),
                                label: Text(
                                  localization.translate('logout'),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
