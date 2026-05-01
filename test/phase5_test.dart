import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/core/errors/app_exception.dart';
import 'package:ethio_liner/core/network/api_client.dart';
import 'package:ethio_liner/features/booking/domain/models/seat_model.dart';
import 'package:ethio_liner/features/booking/presentation/providers/booking_provider.dart';
import 'package:ethio_liner/features/booking/presentation/widgets/seat_lock_countdown_banner.dart';
import 'package:ethio_liner/shared/data/mock_data.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Phase 5 - Transactional Seat Locking & State', () {
    test('BookingDraftState formats countdown mm:ss correctly', () {
      const state1 = BookingDraftState(remainingLockSeconds: 600);
      expect(state1.formattedCountdown, equals('10:00'));

      const state2 = BookingDraftState(remainingLockSeconds: 125);
      expect(state2.formattedCountdown, equals('02:05'));

      const state3 = BookingDraftState(remainingLockSeconds: 59);
      expect(state3.formattedCountdown, equals('00:59'));

      const state4 = BookingDraftState(remainingLockSeconds: 0);
      expect(state4.formattedCountdown, equals('00:00'));
    });

    test('Selecting seat activates lock countdown; deselecting stops it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);

      expect(container.read(bookingDraftProvider).selectedSeats, isEmpty);
      expect(container.read(bookingDraftProvider).isLockExpired, isFalse);

      // Select seat 1A -> countdown initialized
      notifier.toggleSeat('1A');
      expect(container.read(bookingDraftProvider).selectedSeats, contains('1A'));
      expect(container.read(bookingDraftProvider).remainingLockSeconds, equals(600));

      // Deselect seat 1A -> no seats selected, timer stopped
      notifier.toggleSeat('1A');
      expect(container.read(bookingDraftProvider).selectedSeats, isEmpty);
      expect(container.read(bookingDraftProvider).remainingLockSeconds, equals(600));
    });

    test('Seat lock expiration releases reserved seats and marks isLockExpired', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);
      notifier.toggleSeat('1A');
      notifier.toggleSeat('1B');

      expect(container.read(bookingDraftProvider).selectedSeats.length, equals(2));

      // Trigger expiration
      notifier.handleExpiration();

      final state = container.read(bookingDraftProvider);
      expect(state.isLockExpired, isTrue);
      expect(state.selectedSeats, isEmpty);
      expect(state.remainingLockSeconds, equals(0));

      // Verify the previously selected seats returned to available
      final seat1A = state.seats.firstWhere((s) => s.seatNumber == '1A');
      final seat1B = state.seats.firstWhere((s) => s.seatNumber == '1B');
      expect(seat1A.state, equals(SeatState.available));
      expect(seat1B.state, equals(SeatState.available));
    });

    test('Payment cannot proceed if lock is expired', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);
      notifier.toggleSeat('1A');

      // Expire lock
      notifier.handleExpiration();

      final success = await notifier.processSimulatedPayment();
      expect(success, isFalse);
    });
  });

  group('Phase 5 - API Client Concurrency & Conflict Handling', () {
    test('ApiClient maps HTTP 409 to ConflictException', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          '{"detail": "Seat 1A is already locked by another passenger."}',
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(baseUrl: 'http://test', httpClient: mockHttpClient);

      expect(
        () async => await apiClient.post('/api/reservations/lock', body: {'seat_numbers': ['1A']}),
        throwsA(isA<ConflictException>().having(
          (e) => e.message,
          'message',
          contains('Seat 1A is already locked'),
        )),
      );
    });
  });

  group('Phase 5 - UI SeatLockCountdownBanner', () {
    testWidgets('SeatLockCountdownBanner displays formatted time when seats selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      addTearDown(notifier.stopLockCountdown);

      notifier.initializeForTrip(trip);
      notifier.toggleSeat('1A');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SeatLockCountdownBanner(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Seats locked temporarily'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

      notifier.stopLockCountdown();
    });

    testWidgets('SeatLockCountdownBanner renders shrink widget when no seats selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SeatLockCountdownBanner(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Seats locked temporarily'), findsNothing);
    });
  });
}
