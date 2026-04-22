import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/app.dart';
import 'package:ethio_liner/shared/data/mock_data.dart';

void main() {
  test('Mock Ethiopian cities data contains required cities', () {
    expect(ethiopianCities.isNotEmpty, isTrue);
    final cityNames = ethiopianCities.map((c) => c.name).toList();
    expect(cityNames, contains('Addis Ababa'));
    expect(cityNames, contains('Hawassa'));
    expect(cityNames, contains('Bahir Dar'));
    expect(cityNames, contains('Gondar'));
  });

  test('Mock trip repository generates valid trip listings', () {
    final trips = getMockTrips(origin: 'Addis Ababa', destination: 'Hawassa');
    expect(trips.isNotEmpty, isTrue);
    for (final trip in trips) {
      expect(trip.originCity, equals('Addis Ababa'));
      expect(trip.destinationCity, equals('Hawassa'));
      expect(trip.priceEtb, greaterThan(0));
      expect(trip.availableSeats, greaterThan(0));
      expect(trip.operatorName.isNotEmpty, isTrue);
    }
  });

  testWidgets('App launches and displays Splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EthioLinerApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('EthioLiner'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);
  });
}
