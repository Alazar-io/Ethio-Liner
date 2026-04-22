import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/app.dart';

void main() {
  testWidgets('EthioLiner app renders splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EthioLinerApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Verify the app title on splash screen
    expect(find.text('EthioLiner'), findsOneWidget);
    expect(find.text('Ethiopian Intercity Bus Booking'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);
  });
}
