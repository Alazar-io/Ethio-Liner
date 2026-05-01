import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/core/network/api_client.dart';
import 'package:ethio_liner/features/operator/data/operator_repository.dart';
import 'package:ethio_liner/features/operator/domain/models/operator_models.dart';
import 'package:ethio_liner/features/operator/presentation/providers/operator_provider.dart';
import 'package:ethio_liner/features/operator/presentation/screens/operator_dashboard_screen.dart';
import 'package:ethio_liner/features/operator/presentation/screens/passenger_manifest_screen.dart';
import 'package:ethio_liner/features/operator/presentation/screens/qr_boarding_scanner_screen.dart';

void main() {
  group('Phase 6 - Operator Domain Models & Parsing', () {
    test('BoardingStatusX string parsing and display names', () {
      expect(BoardingStatusX.fromString('VALID'), equals(BoardingStatus.valid));
      expect(BoardingStatusX.fromString('ALREADY_BOARDED'), equals(BoardingStatus.alreadyBoarded));
      expect(BoardingStatusX.fromString('CANCELLED'), equals(BoardingStatus.cancelled));
      expect(BoardingStatusX.fromString('EXPIRED'), equals(BoardingStatus.expired));
      expect(BoardingStatusX.fromString('UNKNOWN'), equals(BoardingStatus.invalid));

      expect(BoardingStatus.valid.displayName, equals('Boarding Approved'));
      expect(BoardingStatus.alreadyBoarded.displayName, equals('Already Boarded'));
    });

    test('TripManifest JSON deserialization & calculations', () {
      final json = {
        'trip_id': 1,
        'route': 'Addis Ababa → Hawassa',
        'origin_city': 'Addis Ababa',
        'destination_city': 'Hawassa',
        'departure_time': '2026-10-01T06:00:00Z',
        'departure_terminal': 'Lamberet Terminal',
        'arrival_terminal': 'Hawassa Station',
        'bus_model': 'Yutong Luxury',
        'plate_number': '3-A45124-ET',
        'total_capacity': 48,
        'total_booked': 4,
        'total_boarded': 2,
        'passengers': [
          {
            'ticket_id': 'TCK-001',
            'passenger_name': 'Abebe Bikila',
            'phone_number': '+251911223344',
            'seat_number': '1A',
            'booking_reference': 'ETL-001',
            'status': 'ALREADY_BOARDED',
            'boarded_at': '2026-10-01T05:45:00Z',
          },
          {
            'ticket_id': 'TCK-002',
            'passenger_name': 'Derartu Tulu',
            'phone_number': '+251911334455',
            'seat_number': '1B',
            'booking_reference': 'ETL-001',
            'status': 'VALID',
          },
        ],
      };

      final manifest = TripManifest.fromJson(json);
      expect(manifest.tripId, equals(1));
      expect(manifest.route, equals('Addis Ababa → Hawassa'));
      expect(manifest.totalBooked, equals(4));
      expect(manifest.totalBoarded, equals(2));
      expect(manifest.remainingToBoard, equals(2));
      expect(manifest.passengers.length, equals(2));
      expect(manifest.passengers[0].isBoarded, isTrue);
      expect(manifest.passengers[1].isBoarded, isFalse);
    });
  });

  group('Phase 6 - QR Boarding Validation & Scanner State', () {
    test('Valid QR payload successfully verifies and marks boarded', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = QrBoardingNotifier(repo);

      const qrPayload = 'ETHIOLINER:ETL-2026-78421:TCK-78421-1:1:3A:Abebe Bikila';
      final result = await notifier.validateAndBoard(qrPayload);

      expect(result.status, equals(BoardingStatus.valid));
      expect(result.canBoard, isTrue);
      expect(result.passengerName, equals('Abebe Bikila'));
      expect(result.seatNumber, equals('3A'));
    });

    test('Already boarded QR code is rejected', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = QrBoardingNotifier(repo);

      const qrPayload = 'ETHIOLINER:ETL-2026-78421:TCK-ALREADY:1:3A:Abebe Bikila';
      final result = await notifier.validateAndBoard(qrPayload);

      expect(result.status, equals(BoardingStatus.alreadyBoarded));
      expect(result.canBoard, isFalse);
    });

    test('Cancelled ticket QR code is rejected', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = QrBoardingNotifier(repo);

      const qrPayload = 'TCK-CANCELLED-999';
      final result = await notifier.validateAndBoard(qrPayload);

      expect(result.status, equals(BoardingStatus.cancelled));
      expect(result.canBoard, isFalse);
    });

    test('Bogus string returns invalid ticket status', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = QrBoardingNotifier(repo);

      const qrPayload = 'RANDOM_GARBAGE_STRING';
      final result = await notifier.validateAndBoard(qrPayload);

      expect(result.status, equals(BoardingStatus.invalid));
      expect(result.canBoard, isFalse);
    });
  });

  group('Phase 6 - Passenger Manifest State & Search Filtering', () {
    test('TripManifestNotifier filters passengers by name and seat', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = TripManifestNotifier(repo, 1);

      await notifier.loadManifest();

      // Search by name
      notifier.updateSearchQuery('Abebe');
      expect(notifier.state.filteredPassengers.length, equals(1));
      expect(notifier.state.filteredPassengers.first.passengerName, equals('Abebe Bikila'));

      // Search by seat
      notifier.updateSearchQuery('4A');
      expect(notifier.state.filteredPassengers.length, equals(1));
      expect(notifier.state.filteredPassengers.first.seatNumber, equals('4A'));

      // Clear search
      notifier.updateSearchQuery('');
      expect(notifier.state.filteredPassengers.length, equals(6));
    });

    test('TripManifestNotifier toggles passenger boarded state', () async {
      final repo = ApiOperatorRepository(apiClient: ApiClient(baseUrl: 'http://localhost'));
      final notifier = TripManifestNotifier(repo, 1);

      await notifier.loadManifest();
      final initialBoarded = notifier.state.manifest!.totalBoarded;

      await notifier.toggleBoarding('TCK-99012-1');
      expect(notifier.state.manifest!.totalBoarded, equals(initialBoarded + 1));
    });
  });

  group('Phase 6 - UI Screen Widget Tests', () {
    testWidgets('OperatorDashboardScreen renders analytics and trip cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OperatorDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Operator Portal'), findsOneWidget);
      expect(find.text('Selam Bus Line Operations'), findsOneWidget);
      expect(find.text('QR Boarding Scanner'), findsOneWidget);
      expect(find.text('Operational Overview'), findsOneWidget);
      expect(find.text('Active Trips'), findsOneWidget);
      expect(find.text('Passengers'), findsOneWidget);
      expect(find.text('Fleet Occupancy'), findsOneWidget);
      expect(find.text('Trip Revenue'), findsOneWidget);
      expect(find.text('Addis Ababa → Hawassa'), findsOneWidget);
    });

    testWidgets('QrBoardingScannerScreen renders viewfinder and manual input mode toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QrBoardingScannerScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('QR Boarding Scanner'), findsOneWidget);
      expect(find.text('Scanning for Passenger QR...'), findsOneWidget);
      expect(find.text('Quick Test Simulation:'), findsOneWidget);

      // Switch to manual mode
      await tester.tap(find.byIcon(Icons.keyboard));
      await tester.pump();

      expect(find.text('Manual Boarding Check-In'), findsOneWidget);
      expect(find.text('Verify & Check In'), findsOneWidget);
    });

    testWidgets('PassengerManifestScreen renders passenger tiles and search input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PassengerManifestScreen(tripId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Passenger Manifest'), findsWidgets);
      expect(find.text('Addis Ababa → Hawassa'), findsWidgets);
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Boarded'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('Abebe Bikila'), findsOneWidget);
      expect(find.text('Derartu Tulu'), findsOneWidget);
    });
  });
}
