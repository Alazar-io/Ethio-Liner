import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/core/utils/validators.dart';
import 'package:ethio_liner/features/booking/domain/models/booking_model.dart';
import 'package:ethio_liner/features/booking/domain/models/seat_model.dart';
import 'package:ethio_liner/features/booking/presentation/providers/booking_provider.dart';
import 'package:ethio_liner/shared/data/mock_data.dart';

void main() {
  group('Phase 3 - Seat Selection & Layout', () {
    test('generateBusSeatLayout produces 48 seats with correct columns', () {
      final seats = generateBusSeatLayout(basePriceEtb: 750.0);
      expect(seats.length, equals(48)); // 12 rows * 4 seats
      expect(seats.any((s) => s.seatNumber == '1A'), isTrue);
      expect(seats.any((s) => s.seatNumber == '12D'), isTrue);
    });

    test('Toggling available seat changes state to selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);

      expect(container.read(bookingDraftProvider).selectedSeats, isEmpty);

      // Select 1A
      notifier.toggleSeat('1A');
      expect(container.read(bookingDraftProvider).selectedSeats, contains('1A'));
      expect(container.read(bookingDraftProvider).totalPriceEtb, equals(trip.priceEtb));

      // Select 1B
      notifier.toggleSeat('1B');
      expect(container.read(bookingDraftProvider).selectedSeats.length, equals(2));
      expect(container.read(bookingDraftProvider).totalPriceEtb, equals(trip.priceEtb * 2));

      // Deselect 1A
      notifier.toggleSeat('1A');
      expect(container.read(bookingDraftProvider).selectedSeats, equals(['1B']));
      expect(container.read(bookingDraftProvider).totalPriceEtb, equals(trip.priceEtb));
    });

    test('Occupied seats cannot be toggled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);

      // Seat 2A is occupied in default layout
      notifier.toggleSeat('2A');
      expect(container.read(bookingDraftProvider).selectedSeats, isNot(contains('2A')));
    });
  });

  group('Phase 3 - Passenger Information Validation', () {
    test('Validates Ethiopian phone numbers properly', () {
      expect(Validators.validateEthiopianPhone('+251911223344'), isNull);
      expect(Validators.validateEthiopianPhone('0911223344'), isNull);
      expect(Validators.validateEthiopianPhone('911223344'), isNull);

      // Invalid phone formats
      expect(Validators.validateEthiopianPhone('12345'), isNotNull);
      expect(Validators.validateEthiopianPhone('+14155552671'), isNotNull);
      expect(Validators.validateEthiopianPhone(''), isNotNull);
    });

    test('Validates email addresses properly', () {
      expect(Validators.validateEmail('passenger@example.com'), isNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('Validates passenger names', () {
      expect(Validators.validateName('Abebe Bikila'), isNull);
      expect(Validators.validateName('አበበ ቢቂላ'), isNull); // Amharic name
      expect(Validators.validateName(''), isNotNull);
    });
  });

  group('Phase 3 - Booking & Payment Simulation', () {
    test('Simulated payment creates Booking and DigitalTickets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trip = getMockTrips().first;
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.initializeForTrip(trip);
      notifier.toggleSeat('1A');
      notifier.toggleSeat('1B');

      notifier.setPassengers([
        const Passenger(fullName: 'Passenger One', phoneNumber: '+251911223344', assignedSeat: '1A'),
        const Passenger(fullName: 'Passenger Two', phoneNumber: '+251922334455', assignedSeat: '1B'),
      ]);

      notifier.setPaymentMethod(PaymentMethod.telebirr);

      final result = await notifier.processSimulatedPayment();
      expect(result, isTrue);

      final confirmed = container.read(bookingDraftProvider).confirmedBooking;
      expect(confirmed, isNotNull);
      expect(confirmed!.bookingReference.startsWith('ETL-2026-'), isTrue);
      expect(confirmed.tickets.length, equals(2));
      expect(confirmed.tickets.first.status, equals(TicketStatus.valid));
      expect(confirmed.tickets.first.qrData, contains('ETHIOLINER:'));

      // Check My Trips contains this new booking
      final allTrips = container.read(myTripsProvider);
      expect(allTrips.any((b) => b.bookingReference == confirmed.bookingReference), isTrue);
    });

    test('Cancelling a booking updates status to cancelled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final myTripsNotifier = container.read(myTripsProvider.notifier);
      final initialTrip = container.read(myTripsProvider).first;

      myTripsNotifier.cancelBooking(initialTrip.bookingReference);

      final updated = container.read(myTripsProvider).firstWhere(
        (b) => b.bookingReference == initialTrip.bookingReference,
      );
      expect(updated.paymentStatus, equals(PaymentStatus.cancelled));
      expect(updated.tickets.first.status, equals(TicketStatus.cancelled));
    });
  });
}
