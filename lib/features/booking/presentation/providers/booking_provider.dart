import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/models/trip_models.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/seat_model.dart';

/// Draft state while the user is undergoing the booking process.
class BookingDraftState {
  const BookingDraftState({
    this.trip,
    this.seats = const [],
    this.selectedSeats = const [],
    this.passengers = const [],
    this.paymentMethod = PaymentMethod.telebirr,
    this.paymentStatus = PaymentStatus.pending,
    this.confirmedBooking,
    this.remainingLockSeconds = 600,
    this.isLockExpired = false,
  });

  final Trip? trip;
  final List<BusSeat> seats;
  final List<String> selectedSeats;
  final List<Passenger> passengers;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final Booking? confirmedBooking;
  final int remainingLockSeconds;
  final bool isLockExpired;

  double get totalPriceEtb {
    if (trip == null) return 0.0;
    return trip!.priceEtb * selectedSeats.length;
  }

  String get formattedCountdown {
    final mins = remainingLockSeconds ~/ 60;
    final secs = remainingLockSeconds % 60;
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  BookingDraftState copyWith({
    Trip? trip,
    List<BusSeat>? seats,
    List<String>? selectedSeats,
    List<Passenger>? passengers,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    Booking? confirmedBooking,
    int? remainingLockSeconds,
    bool? isLockExpired,
  }) {
    return BookingDraftState(
      trip: trip ?? this.trip,
      seats: seats ?? this.seats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      passengers: passengers ?? this.passengers,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
      remainingLockSeconds: remainingLockSeconds ?? this.remainingLockSeconds,
      isLockExpired: isLockExpired ?? this.isLockExpired,
    );
  }
}

/// State notifier managing the active booking flow draft and seat reservation locks.
class BookingDraftNotifier extends StateNotifier<BookingDraftState> {
  BookingDraftNotifier(this.ref) : super(const BookingDraftState());

  final Ref ref;
  Timer? _countdownTimer;

  void initializeForTrip(Trip trip) {
    stopLockCountdown();
    final seatLayout = generateBusSeatLayout(basePriceEtb: trip.priceEtb);
    state = BookingDraftState(
      trip: trip,
      seats: seatLayout,
      selectedSeats: const [],
      passengers: const [],
      remainingLockSeconds: 600,
      isLockExpired: false,
    );
  }

  void toggleSeat(String seatNumber) {
    final currentSelected = List<String>.from(state.selectedSeats);
    final currentSeats = state.seats.map((seat) {
      if (seat.seatNumber == seatNumber) {
        if (seat.state == SeatState.occupied || seat.state == SeatState.unavailable) {
          return seat;
        }
        if (currentSelected.contains(seatNumber)) {
          currentSelected.remove(seatNumber);
          return seat.copyWith(state: SeatState.available);
        } else {
          currentSelected.add(seatNumber);
          return seat.copyWith(state: SeatState.selected);
        }
      }
      return seat;
    }).toList();

    state = state.copyWith(
      seats: currentSeats,
      selectedSeats: currentSelected,
    );

    if (currentSelected.isNotEmpty) {
      startLockCountdown();
    } else {
      stopLockCountdown();
      state = state.copyWith(remainingLockSeconds: 600);
    }
  }

  void startLockCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(remainingLockSeconds: 600, isLockExpired: false);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingLockSeconds > 1) {
        state = state.copyWith(remainingLockSeconds: state.remainingLockSeconds - 1);
      } else {
        timer.cancel();
        // Expired! Release locks
        handleExpiration();
      }
    });
  }

  void stopLockCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void handleExpiration() {
    stopLockCountdown();
    final releasedSeats = state.seats.map((s) {
      if (s.state == SeatState.selected) {
        return s.copyWith(state: SeatState.available);
      }
      return s;
    }).toList();

    state = state.copyWith(
      seats: releasedSeats,
      selectedSeats: const [],
      remainingLockSeconds: 0,
      isLockExpired: true,
    );
  }

  void setPassengers(List<Passenger> passengers) {
    state = state.copyWith(passengers: passengers);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<bool> processSimulatedPayment() async {
    state = state.copyWith(paymentStatus: PaymentStatus.processing);

    // Simulate payment transaction network latency
    await Future.delayed(const Duration(milliseconds: 1800));

    if (state.trip == null || state.selectedSeats.isEmpty || state.isLockExpired) {
      state = state.copyWith(paymentStatus: PaymentStatus.failed);
      return false;
    }

    final randomId = 10000 + Random().nextInt(90000);
    final bookingRef = 'ETL-2026-$randomId';

    // Generate individual tickets for each passenger/seat
    final List<DigitalTicket> tickets = [];
    for (int i = 0; i < state.selectedSeats.length; i++) {
      final seatNum = state.selectedSeats[i];
      final passenger = (i < state.passengers.length)
          ? state.passengers[i]
          : Passenger(
              fullName: 'Passenger ${i + 1}',
              phoneNumber: '+251911223344',
            );

      final ticketId = 'TCK-$randomId-${i + 1}';
      final qrData = 'ETHIOLINER:$bookingRef:$ticketId:${state.trip!.id}:$seatNum:${passenger.fullName}';

      tickets.add(
        DigitalTicket(
          ticketId: ticketId,
          bookingReference: bookingRef,
          passengerName: passenger.fullName,
          passengerPhone: passenger.phoneNumber,
          trip: state.trip!,
          seatNumber: seatNum,
          status: TicketStatus.valid,
          qrData: qrData,
          issuedAt: DateTime.now(),
        ),
      );
    }

    final booking = Booking(
      bookingReference: bookingRef,
      trip: state.trip!,
      passengers: state.passengers,
      selectedSeats: state.selectedSeats,
      totalPriceEtb: state.totalPriceEtb,
      paymentMethod: state.paymentMethod,
      paymentStatus: PaymentStatus.success,
      createdAt: DateTime.now(),
      tickets: tickets,
    );

    stopLockCountdown();

    state = state.copyWith(
      paymentStatus: PaymentStatus.success,
      confirmedBooking: booking,
    );

    // Add to My Trips store for offline ticket access
    ref.read(myTripsProvider.notifier).addBooking(booking);

    return true;
  }

  void reset() {
    stopLockCountdown();
    state = const BookingDraftState();
  }

  @override
  void dispose() {
    stopLockCountdown();
    super.dispose();
  }
}

/// Provider for booking draft state.
final bookingDraftProvider = StateNotifierProvider<BookingDraftNotifier, BookingDraftState>((ref) {
  return BookingDraftNotifier(ref);
});

/// Notifier managing persistent passenger bookings (My Trips).
class MyTripsNotifier extends StateNotifier<List<Booking>> {
  MyTripsNotifier() : super(_initialMockBookings());

  static List<Booking> _initialMockBookings() {
    final mockTrip = getMockTrips().first;
    const bookingRef = 'ETL-2026-78421';
    final ticket = DigitalTicket(
      ticketId: 'TCK-78421-1',
      bookingReference: bookingRef,
      passengerName: 'Abebe Bikila',
      passengerPhone: '+251911223344',
      trip: mockTrip,
      seatNumber: '3A',
      status: TicketStatus.valid,
      qrData: 'ETHIOLINER:$bookingRef:TCK-78421-1:${mockTrip.id}:3A:Abebe Bikila',
      issuedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    return [
      Booking(
        bookingReference: bookingRef,
        trip: mockTrip,
        passengers: const [
          Passenger(
            fullName: 'Abebe Bikila',
            phoneNumber: '+251911223344',
            assignedSeat: '3A',
          ),
        ],
        selectedSeats: const ['3A'],
        totalPriceEtb: mockTrip.priceEtb,
        paymentMethod: PaymentMethod.telebirr,
        paymentStatus: PaymentStatus.success,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tickets: [ticket],
      ),
    ];
  }

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  void cancelBooking(String bookingReference) {
    state = state.map((b) {
      if (b.bookingReference == bookingReference) {
        final updatedTickets = b.tickets
            .map((t) => DigitalTicket(
                  ticketId: t.ticketId,
                  bookingReference: t.bookingReference,
                  passengerName: t.passengerName,
                  passengerPhone: t.passengerPhone,
                  trip: t.trip,
                  seatNumber: t.seatNumber,
                  status: TicketStatus.cancelled,
                  qrData: t.qrData,
                  issuedAt: t.issuedAt,
                ))
            .toList();

        return Booking(
          bookingReference: b.bookingReference,
          trip: b.trip,
          passengers: b.passengers,
          selectedSeats: b.selectedSeats,
          totalPriceEtb: b.totalPriceEtb,
          paymentMethod: b.paymentMethod,
          paymentStatus: PaymentStatus.cancelled,
          createdAt: b.createdAt,
          tickets: updatedTickets,
        );
      }
      return b;
    }).toList();
  }
}

/// Provider for user bookings list.
final myTripsProvider = StateNotifierProvider<MyTripsNotifier, List<Booking>>((ref) {
  return MyTripsNotifier();
});
