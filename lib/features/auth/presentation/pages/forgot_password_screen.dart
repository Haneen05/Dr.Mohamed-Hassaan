import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_loading_dialog.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  final AuthLoadingDialogController _loadingDialog =
      AuthLoadingDialogController();

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void _sendResetEmail() {
    final localization = AppLocalizations.of(context);

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('resetPasswordEmptyEmail')),
        ),
      );

      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _loadingDialog.show(context);

          return;
        }

        if (state is AuthPasswordResetSuccess) {
          _loadingDialog.hide(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localization.translate('resetEmailSent'))),
          );

          Navigator.pop(context);

          return;
        }

        if (state is AuthError) {
          _loadingDialog.hide(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.translate(state.localizationKey)),
              backgroundColor: colorScheme.primary,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(24, 18, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AuthBackButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthHeader(
                    title: localization.translate('forgotPasswordTitle'),
                    subtitle: localization.translate('forgotPasswordSubtitle'),
                    showLogo: true,
                  ),
                  const SizedBox(height: 34),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localization.translate('email'),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _emailController,
                          hintText: localization.translate('enterEmail'),
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: localization.translate('sendResetLink'),
                    onPressed: _sendResetEmail,
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
