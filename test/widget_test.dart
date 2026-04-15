import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/app.dart';

void main() {
  testWidgets('EthioLiner app renders home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EthioLinerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the app title is displayed
    expect(find.text('EthioLiner'), findsWidgets);

    // Verify the tagline is displayed
    expect(find.text('Ethiopian Intercity Bus Booking'), findsOneWidget);

    // Verify the search button exists
    expect(find.text('Search Trips'), findsOneWidget);

    // Verify the bus icon is displayed
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
  });
}
