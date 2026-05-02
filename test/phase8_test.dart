import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethio_liner/core/widgets/app_button.dart';
import 'package:ethio_liner/core/widgets/app_card.dart';
import 'package:ethio_liner/core/widgets/empty_widget.dart';
import 'package:ethio_liner/core/widgets/error_widget.dart';
import 'package:ethio_liner/core/widgets/loading_widget.dart';

void main() {
  group('Phase 8 - Production Documentation Integrity', () {
    test('Required system documentation files exist and are populated', () {
      final docFiles = [
        'README.md',
        'ARCHITECTURE.md',
        'API_SPEC.md',
        'DATABASE_SCHEMA.md',
        'DEVELOPMENT.md',
      ];

      for (final doc in docFiles) {
        final file = File(doc);
        expect(file.existsSync(), isTrue, reason: 'Expected $doc to exist');
        final content = file.readAsStringSync();
        expect(content.length, greaterThan(300), reason: '$doc should have substantial documentation content');
      }
    });

    test('ARCHITECTURE.md contains core architecture definitions', () {
      final content = File('ARCHITECTURE.md').readAsStringSync();
      expect(content.toLowerCase().contains('clean architecture'), isTrue);
      expect(content.contains('FastAPI'), isTrue);
      expect(content.contains('Riverpod'), isTrue);
      expect(content.contains('Ethiopian Calendar'), isTrue);
      expect(content.contains('HMAC-SHA256'), isTrue);
    });

    test('API_SPEC.md documents all primary endpoint contracts', () {
      final content = File('API_SPEC.md').readAsStringSync();
      expect(content.contains('/auth/login'), isTrue);
      expect(content.contains('/trips'), isTrue);
      expect(content.contains('/trips/{trip_id}/reserve'), isTrue);
      expect(content.contains('/bookings/confirm'), isTrue);
      expect(content.contains('/operator/tickets/validate-qr'), isTrue);
    });

    test('DATABASE_SCHEMA.md documents core relational tables and enums', () {
      final content = File('DATABASE_SCHEMA.md').readAsStringSync();
      expect(content.contains('users'), isTrue);
      expect(content.contains('buses'), isTrue);
      expect(content.contains('trips'), isTrue);
      expect(content.contains('reservations'), isTrue);
      expect(content.contains('bookings'), isTrue);
      expect(content.contains('tickets'), isTrue);
      expect(content.contains('payments'), isTrue);
    });
  });

  group('Phase 8 - UI/UX Polish & Design System Widgets', () {
    testWidgets('AppLoadingWidget renders spinner and message cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingWidget(message: 'Securing seat reservation...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Securing seat reservation...'), findsOneWidget);
    });

    testWidgets('AppErrorWidget renders error state and triggers retry', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Network connection lost. Please check connection.',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Network connection lost. Please check connection.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('AppEmptyWidget renders empty state and action button', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyWidget(
              message: 'No upcoming trips found.',
              actionLabel: 'Discover Trips',
              onAction: () => actionPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No upcoming trips found.'), findsOneWidget);
      expect(find.text('Discover Trips'), findsOneWidget);

      await tester.tap(find.text('Discover Trips'));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('AppButton variants render with correct styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppButton(
                  text: 'Primary Action',
                  variant: AppButtonVariant.primary,
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Outlined Action',
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.text('Outlined Action'), findsOneWidget);
    });

    testWidgets('AppCard renders child with elevated card container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Card Content Test'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });
  });
}
