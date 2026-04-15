import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget of the EthioLiner application.
///
/// Configures MaterialApp with:
/// - Material 3 theming (light and dark)
/// - GoRouter for declarative navigation
/// - App-level configuration
class EthioLinerApp extends StatelessWidget {
  const EthioLinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EthioLiner',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: goRouter,
    );
  }
}
