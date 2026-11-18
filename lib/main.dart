import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/localization/locale_state.dart';
import 'core/notifications/notification_navigation_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/routing/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/quran/presentation/cubit/mushaf_theme_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await initDependencies();

  runApp(const IslamicScholarApp());

  unawaited(
    NotificationService.instance.initialize().catchError((Object error) {
      debugPrint('NOTIFICATION INITIALIZATION ERROR: $error');
    }),
  );
}

class IslamicScholarApp extends StatelessWidget {
  const IslamicScholarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        392.72727272727275,
        800.7272727272727,
      ),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (_) => sl<AuthCubit>(),
            ),
            BlocProvider<LocaleCubit>(
              create: (_) => LocaleCubit(),
            ),
            BlocProvider<ThemeCubit>(
              create: (_) => ThemeCubit(),
            ),
            BlocProvider<MushafThemeCubit>(
              create: (_) => sl<MushafThemeCubit>()..load(),
            ),
          ],
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              final localeCubit = context.read<LocaleCubit>();

              return BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return MaterialApp(
                    navigatorKey: AppNavigator.key,
                    debugShowCheckedModeBanner: false,
                    title: 'Islamic Scholar',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,
                    locale: localeCubit.currentLocale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    builder: (context, child) {
                      return NotificationNavigationHandler(
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                    home: const AuthGate(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
