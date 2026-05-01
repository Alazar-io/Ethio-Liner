/// Domain models for Operator platform, manifests, and QR boarding.
library;

enum BoardingStatus {
  valid,
  alreadyBoarded,
  cancelled,
  expired,
  invalid,
}

extension BoardingStatusX on BoardingStatus {
  String get displayName {
    switch (this) {
      case BoardingStatus.valid:
        return 'Boarding Approved';
      case BoardingStatus.alreadyBoarded:
        return 'Already Boarded';
      case BoardingStatus.cancelled:
        return 'Ticket Cancelled';
      case BoardingStatus.expired:
        return 'Ticket Expired';
      case BoardingStatus.invalid:
        return 'Invalid Ticket';
    }
  }

  static BoardingStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'VALID':
        return BoardingStatus.valid;
      case 'ALREADY_BOARDED':
        return BoardingStatus.alreadyBoarded;
      case 'CANCELLED':
        return BoardingStatus.cancelled;
      case 'EXPIRED':
        return BoardingStatus.expired;
      default:
        return BoardingStatus.invalid;
    }
  }
}

/// Result of scanning or verifying a digital QR boarding pass.
class BoardingValidationResult {
  const BoardingValidationResult({
    required this.status,
    required this.message,
    required this.canBoard,
    this.ticketId,
    this.passengerName,
    this.seatNumber,
    this.route,
    this.boardedAt,
  });

  final BoardingStatus status;
  final String message;
  final bool canBoard;
  final String? ticketId;
  final String? passengerName;
  final String? seatNumber;
  final String? route;
  final DateTime? boardedAt;

  factory BoardingValidationResult.fromJson(Map<String, dynamic> json) {
    return BoardingValidationResult(
      status: BoardingStatusX.fromString(json['status']?.toString() ?? 'INVALID'),
      message: json['message']?.toString() ?? '',
      canBoard: json['can_board'] == true,
      ticketId: json['ticket_id']?.toString(),
      passengerName: json['passenger_name']?.toString(),
      seatNumber: json['seat_number']?.toString(),
      route: json['route']?.toString(),
      boardedAt: json['boarded_at'] != null
          ? DateTime.tryParse(json['boarded_at'].toString())
          : null,
    );
  }
}

/// Passenger entry on a trip manifest.
class ManifestPassenger {
  const ManifestPassenger({
    required this.ticketId,
    required this.passengerName,
    required this.phoneNumber,
    required this.seatNumber,
    required this.bookingReference,
    required this.status,
    this.boardedAt,
  });

  final String ticketId;
  final String passengerName;
  final String phoneNumber;
  final String seatNumber;
  final String bookingReference;
  final BoardingStatus status;
  final DateTime? boardedAt;

  bool get isBoarded => status == BoardingStatus.alreadyBoarded;

  ManifestPassenger copyWith({
    String? ticketId,
    String? passengerName,
    String? phoneNumber,
    String? seatNumber,
    String? bookingReference,
    BoardingStatus? status,
    DateTime? boardedAt,
  }) {
    return ManifestPassenger(
      ticketId: ticketId ?? this.ticketId,
      passengerName: passengerName ?? this.passengerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      bookingReference: bookingReference ?? this.bookingReference,
      status: status ?? this.status,
      boardedAt: boardedAt ?? this.boardedAt,
    );
  }

  factory ManifestPassenger.fromJson(Map<String, dynamic> json) {
    return ManifestPassenger(
      ticketId: json['ticket_id']?.toString() ?? '',
      passengerName: json['passenger_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      seatNumber: json['seat_number']?.toString() ?? '',
      bookingReference: json['booking_reference']?.toString() ?? '',
      status: BoardingStatusX.fromString(json['status']?.toString() ?? 'VALID'),
      boardedAt: json['boarded_at'] != null
          ? DateTime.tryParse(json['boarded_at'].toString())
          : null,
    );
  }
}

/// Manifest summary for a specific trip.
class TripManifest {
  const TripManifest({
    required this.tripId,
    required this.route,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.departureTerminal,
    required this.arrivalTerminal,
    required this.busModel,
    required this.plateNumber,
    required this.totalCapacity,
    required this.totalBooked,
    required this.totalBoarded,
    required this.passengers,
  });

  final int tripId;
  final String route;
  final String originCity;
  final String destinationCity;
  final DateTime departureTime;
  final String departureTerminal;
  final String arrivalTerminal;
  final String busModel;
  final String plateNumber;
  final int totalCapacity;
  final int totalBooked;
  final int totalBoarded;
  final List<ManifestPassenger> passengers;

  int get remainingToBoard => totalBooked - totalBoarded;

  factory TripManifest.fromJson(Map<String, dynamic> json) {
    final rawPassengers = json['passengers'] as List? ?? [];
    return TripManifest(
      tripId: json['trip_id'] as int? ?? 0,
      route: json['route']?.toString() ?? '',
      originCity: json['origin_city']?.toString() ?? '',
      destinationCity: json['destination_city']?.toString() ?? '',
      departureTime: DateTime.tryParse(json['departure_time']?.toString() ?? '') ?? DateTime.now(),
      departureTerminal: json['departure_terminal']?.toString() ?? '',
      arrivalTerminal: json['arrival_terminal']?.toString() ?? '',
      busModel: json['bus_model']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      totalCapacity: json['total_capacity'] as int? ?? 48,
      totalBooked: json['total_booked'] as int? ?? 0,
      totalBoarded: json['total_boarded'] as int? ?? 0,
      passengers: rawPassengers
          .map((p) => ManifestPassenger.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Operator trip overview item.
class OperatorTrip {
  const OperatorTrip({
    required this.tripId,
    required this.route,
    required this.originCity,
    required this.destinationCity,
    required this.busModel,
    required this.plateNumber,
    required this.departureTime,
    required this.priceEtb,
    required this.totalSeats,
    required this.bookedSeats,
    required this.boardedPassengers,
    required this.occupancyRate,
    required this.status,
  });

  final int tripId;
  final String route;
  final String originCity;
  final String destinationCity;
  final String busModel;
  final String plateNumber;
  final DateTime departureTime;
  final double priceEtb;
  final int totalSeats;
  final int bookedSeats;
  final int boardedPassengers;
  final double occupancyRate;
  final String status;

  factory OperatorTrip.fromJson(Map<String, dynamic> json) {
    return OperatorTrip(
      tripId: json['trip_id'] as int? ?? 0,
      route: json['route']?.toString() ?? '',
      originCity: json['origin_city']?.toString() ?? '',
      destinationCity: json['destination_city']?.toString() ?? '',
      busModel: json['bus_model']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      departureTime: DateTime.tryParse(json['departure_time']?.toString() ?? '') ?? DateTime.now(),
      priceEtb: (json['price_etb'] as num?)?.toDouble() ?? 0.0,
      totalSeats: json['total_seats'] as int? ?? 48,
      bookedSeats: json['booked_seats'] as int? ?? 0,
      boardedPassengers: json['boarded_passengers'] as int? ?? 0,
      occupancyRate: (json['occupancy_rate'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'SCHEDULED',
    );
  }
}

/// Overview dashboard data for bus fleet operators.
class OperatorOverview {
  const OperatorOverview({
    required this.operatorName,
    required this.isVerified,
    required this.totalBuses,
    required this.totalRoutes,
    required this.totalTrips,
    required this.activeTripsToday,
    required this.totalPassengersBooked,
    required this.totalPassengersBoarded,
    required this.occupancyRatePercent,
    required this.totalRevenueEtb,
    required this.trips,
  });

  final String operatorName;
  final bool isVerified;
  final int totalBuses;
  final int totalRoutes;
  final int totalTrips;
  final int activeTripsToday;
  final int totalPassengersBooked;
  final int totalPassengersBoarded;
  final double occupancyRatePercent;
  final double totalRevenueEtb;
  final List<OperatorTrip> trips;

  factory OperatorOverview.fromJson(Map<String, dynamic> json) {
    final rawTrips = json['trips'] as List? ?? [];
    return OperatorOverview(
      operatorName: json['operator_name']?.toString() ?? 'Selam Bus Line',
      isVerified: json['is_verified'] == true,
      totalBuses: json['total_buses'] as int? ?? 0,
      totalRoutes: json['total_routes'] as int? ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
      activeTripsToday: json['active_trips_today'] as int? ?? 0,
      totalPassengersBooked: json['total_passengers_booked'] as int? ?? 0,
      totalPassengersBoarded: json['total_passengers_boarded'] as int? ?? 0,
      occupancyRatePercent: (json['occupancy_rate_percent'] as num?)?.toDouble() ?? 0.0,
      totalRevenueEtb: (json['total_revenue_etb'] as num?)?.toDouble() ?? 0.0,
      trips: rawTrips
          .map((t) => OperatorTrip.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
