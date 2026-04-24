import 'package:equatable/equatable.dart';
import '../../../../shared/models/trip_models.dart';

/// Representation of a passenger for a bus booking.
class Passenger extends Equatable {
  const Passenger({
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.assignedSeat,
  });

  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? assignedSeat;

  Passenger copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? assignedSeat,
  }) {
    return Passenger(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      assignedSeat: assignedSeat ?? this.assignedSeat,
    );
  }

  @override
  List<Object?> get props => [fullName, phoneNumber, email, assignedSeat];
}

/// Simulated Ethiopian payment methods.
enum PaymentMethod {
  telebirr,
  cbeBirr,
  awashBirr,
  cash,
}

extension PaymentMethodX on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'telebirr';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr';
      case PaymentMethod.awashBirr:
        return 'Awash Birr';
      case PaymentMethod.cash:
        return 'Pay at Terminal';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'Fast mobile payment via Ethio Telecom';
      case PaymentMethod.cbeBirr:
        return 'Commercial Bank of Ethiopia Mobile Banking';
      case PaymentMethod.awashBirr:
        return 'Awash Bank digital mobile wallet';
      case PaymentMethod.cash:
        return 'Pay cash directly at terminal prior to departure';
    }
  }
}

/// Status of the payment transaction.
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
}

/// Digital ticket status.
enum TicketStatus {
  valid,
  boarded,
  cancelled,
  expired,
}

/// Representation of a confirmed booking.
class Booking extends Equatable {
  const Booking({
    required this.bookingReference,
    required this.trip,
    required this.passengers,
    required this.selectedSeats,
    required this.totalPriceEtb,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.tickets,
  });

  final String bookingReference;
  final Trip trip;
  final List<Passenger> passengers;
  final List<String> selectedSeats;
  final double totalPriceEtb;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final List<DigitalTicket> tickets;

  @override
  List<Object?> get props => [
        bookingReference,
        trip,
        passengers,
        selectedSeats,
        totalPriceEtb,
        paymentMethod,
        paymentStatus,
        createdAt,
        tickets,
      ];
}

/// Representation of an individual digital QR ticket.
class DigitalTicket extends Equatable {
  const DigitalTicket({
    required this.ticketId,
    required this.bookingReference,
    required this.passengerName,
    required this.passengerPhone,
    required this.trip,
    required this.seatNumber,
    required this.status,
    required this.qrData,
    required this.issuedAt,
  });

  final String ticketId;
  final String bookingReference;
  final String passengerName;
  final String passengerPhone;
  final Trip trip;
  final String seatNumber;
  final TicketStatus status;
  final String qrData;
  final DateTime issuedAt;

  @override
  List<Object?> get props => [
        ticketId,
        bookingReference,
        passengerName,
        passengerPhone,
        trip,
        seatNumber,
        status,
        qrData,
        issuedAt,
      ];
}
