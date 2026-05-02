import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget of the EthioLiner application.
///
/// Configures MaterialApp with:
/// - Material 3 theming (light and dark)
/// - GoRouter for declarative navigation
/// - Tri-lingual internationalization (English, Amharic, Afaan Oromo)
class EthioLinerApp extends ConsumerWidget {
  const EthioLinerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'EthioLiner',
      debugShowCheckedModeBanner: false,

      // Localization
      locale: activeLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: goRouter,
    );
  }
}
