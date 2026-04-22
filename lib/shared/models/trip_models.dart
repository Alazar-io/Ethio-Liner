import 'package:equatable/equatable.dart';

/// Representation of an Ethiopian city destination/origin.
class City extends Equatable {
  const City({
    required this.id,
    required this.name,
    required this.region,
    this.amharicName,
    this.isPopular = false,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String region;
  final String? amharicName;
  final bool isPopular;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, region, amharicName, isPopular, imageUrl];
}

/// Representation of a bus operator (e.g., Selam Bus, Abay Bus).
class BusOperator extends Equatable {
  const BusOperator({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    this.logoUrl,
    this.phone,
  });

  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String? logoUrl;
  final String? phone;

  @override
  List<Object?> get props => [id, name, rating, reviewCount, logoUrl, phone];
}

/// Representation of a bus vehicle.
class Bus extends Equatable {
  const Bus({
    required this.id,
    required this.operatorId,
    required this.plateNumber,
    required this.busModel,
    required this.totalSeats,
    required this.amenities,
  });

  final String id;
  final String operatorId;
  final String plateNumber;
  final String busModel; // e.g. Yutong 2023, Scania Marcopolo
  final int totalSeats;
  final List<String> amenities; // WiFi, AC, USB Charger, Water, TV

  @override
  List<Object?> get props => [id, operatorId, plateNumber, busModel, totalSeats, amenities];
}

/// Search query model for trip searches.
class SearchQuery extends Equatable {
  const SearchQuery({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.passengerCount = 1,
  });

  final City origin;
  final City destination;
  final DateTime departureDate;
  final int passengerCount;

  @override
  List<Object?> get props => [origin, destination, departureDate, passengerCount];

  SearchQuery copyWith({
    City? origin,
    City? destination,
    DateTime? departureDate,
    int? passengerCount,
  }) {
    return SearchQuery(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      passengerCount: passengerCount ?? this.passengerCount,
    );
  }
}

/// Representation of an intercity trip.
class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.operatorName,
    required this.operatorRating,
    required this.busModel,
    required this.originCity,
    required this.destinationCity,
    required this.departureTerminal,
    required this.arrivalTerminal,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.priceEtb,
    required this.availableSeats,
    required this.totalSeats,
    required this.amenities,
    this.isDiscounted = false,
  });

  final String id;
  final String operatorName;
  final double operatorRating;
  final String busModel;
  final String originCity;
  final String destinationCity;
  final String departureTerminal;
  final String arrivalTerminal;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int durationMinutes;
  final double priceEtb;
  final int availableSeats;
  final int totalSeats;
  final List<String> amenities;
  final bool isDiscounted;

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  List<Object?> get props => [
        id,
        operatorName,
        operatorRating,
        busModel,
        originCity,
        destinationCity,
        departureTerminal,
        arrivalTerminal,
        departureTime,
        arrivalTime,
        durationMinutes,
        priceEtb,
        availableSeats,
        totalSeats,
        amenities,
        isDiscounted,
      ];
}
