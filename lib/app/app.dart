import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import '../features/auth/data/auth_repository.dart';

class EduMindApp extends ConsumerWidget {
  const EduMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final storage = ref.watch(storageServiceProvider);
    final authState = ref.watch(authNotifierProvider);
    final isDark = ref.watch(themeProvider);

    final fontScale =
        authState.user?.accessibility.fontScale ?? storage.getFontScale();
    final highContrast =
        authState.user?.accessibility.highContrast ?? storage.isHighContrast();

    return MaterialApp.router(
      title: 'EduMind AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(
        isDark: isDark,
        fontScale: fontScale,
        highContrast: highContrast,
      ),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('kk', 'KZ'),
        Locale('en', 'US'),
      ],
    );
  }
}
