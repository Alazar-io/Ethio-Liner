import '../models/trip_models.dart';

/// Predefined list of Ethiopian cities for origins and destinations.
final List<City> ethiopianCities = [
  const City(
    id: 'addis_ababa',
    name: 'Addis Ababa',
    region: 'Addis Ababa',
    amharicName: 'አዲስ አበባ',
    isPopular: true,
  ),
  const City(
    id: 'adama',
    name: 'Adama (Nazret)',
    region: 'Oromia',
    amharicName: 'አዳማ',
    isPopular: true,
  ),
  const City(
    id: 'hawassa',
    name: 'Hawassa',
    region: 'Sidama',
    amharicName: 'ሐዋሳ',
    isPopular: true,
  ),
  const City(
    id: 'bahir_dar',
    name: 'Bahir Dar',
    region: 'Amhara',
    amharicName: 'ባሕር ዳር',
    isPopular: true,
  ),
  const City(
    id: 'gondar',
    name: 'Gondar',
    region: 'Amhara',
    amharicName: 'ጎንደር',
    isPopular: true,
  ),
  const City(
    id: 'dire_dawa',
    name: 'Dire Dawa',
    region: 'Dire Dawa',
    amharicName: 'ድሬዳዋ',
    isPopular: true,
  ),
  const City(
    id: 'mekelle',
    name: 'Mekelle',
    region: 'Tigray',
    amharicName: 'መቀሌ',
    isPopular: false,
  ),
  const City(
    id: 'jimma',
    name: 'Jimma',
    region: 'Oromia',
    amharicName: 'ጅማ',
    isPopular: false,
  ),
  const City(
    id: 'dessie',
    name: 'Dessie',
    region: 'Amhara',
    amharicName: 'ደሴ',
    isPopular: false,
  ),
  const City(
    id: 'bishoftu',
    name: 'Bishoftu (Debre Zeit)',
    region: 'Oromia',
    amharicName: 'ቢሾፍቱ',
    isPopular: false,
  ),
];

/// Sample Ethiopian bus operators.
final List<BusOperator> mockOperators = [
  const BusOperator(id: 'op_selam', name: 'Selam Bus', rating: 4.8, reviewCount: 1420),
  const BusOperator(id: 'op_abay', name: 'Abay Bus', rating: 4.6, reviewCount: 980),
  const BusOperator(id: 'op_golden', name: 'Golden Bus', rating: 4.7, reviewCount: 1100),
  const BusOperator(id: 'op_oda', name: 'Oda Bus', rating: 4.5, reviewCount: 760),
  const BusOperator(id: 'op_zemen', name: 'Zemen Bus', rating: 4.9, reviewCount: 1650),
];

/// Generates mock trips based on search query or default listing.
List<Trip> getMockTrips({
  String? origin,
  String? destination,
  DateTime? date,
}) {
  final now = date ?? DateTime.now().add(const Duration(days: 1));
  final baseDate = DateTime(now.year, now.month, now.day);

  final allTrips = [
    Trip(
      id: 'trip_101',
      operatorName: 'Selam Bus',
      operatorRating: 4.8,
      busModel: 'Yutong Luxury 2024',
      originCity: origin ?? 'Addis Ababa',
      destinationCity: destination ?? 'Hawassa',
      departureTerminal: 'Lamberet Bus Station',
      arrivalTerminal: 'Hawassa Central Terminal',
      departureTime: baseDate.add(const Duration(hours: 6, minutes: 0)), // 6:00 AM
      arrivalTime: baseDate.add(const Duration(hours: 10, minutes: 30)), // 10:30 AM
      durationMinutes: 270,
      priceEtb: 750.0,
      availableSeats: 14,
      totalSeats: 49,
      amenities: const ['WiFi', 'Air Conditioning', 'USB Charger', 'Bottled Water'],
    ),
    Trip(
      id: 'trip_102',
      operatorName: 'Zemen Bus',
      operatorRating: 4.9,
      busModel: 'Scania Marcopolo VIP',
      originCity: origin ?? 'Addis Ababa',
      destinationCity: destination ?? 'Hawassa',
      departureTerminal: 'Kality Bus Station',
      arrivalTerminal: 'Hawassa Main Bus Station',
      departureTime: baseDate.add(const Duration(hours: 7, minutes: 30)), // 7:30 AM
      arrivalTime: baseDate.add(const Duration(hours: 11, minutes: 45)), // 11:45 AM
      durationMinutes: 255,
      priceEtb: 850.0,
      availableSeats: 8,
      totalSeats: 45,
      amenities: const ['WiFi', 'AC', 'Reclining Seats', 'TV', 'Snack Service'],
      isDiscounted: true,
    ),
    Trip(
      id: 'trip_103',
      operatorName: 'Abay Bus',
      operatorRating: 4.6,
      busModel: 'Golden Dragon Express',
      originCity: origin ?? 'Addis Ababa',
      destinationCity: destination ?? 'Bahir Dar',
      departureTerminal: 'Asko Central Terminal',
      arrivalTerminal: 'Bahir Dar Main Terminal',
      departureTime: baseDate.add(const Duration(hours: 5, minutes: 30)), // 5:30 AM
      arrivalTime: baseDate.add(const Duration(hours: 14, minutes: 0)), // 2:00 PM
      durationMinutes: 510,
      priceEtb: 1200.0,
      availableSeats: 22,
      totalSeats: 55,
      amenities: const ['Air Conditioning', 'TV', 'USB Charger'],
    ),
    Trip(
      id: 'trip_104',
      operatorName: 'Golden Bus',
      operatorRating: 4.7,
      busModel: 'King Long Luxury',
      originCity: origin ?? 'Addis Ababa',
      destinationCity: destination ?? 'Adama',
      departureTerminal: 'Kality Bus Station',
      arrivalTerminal: 'Adama Express Terminal',
      departureTime: baseDate.add(const Duration(hours: 8, minutes: 0)),
      arrivalTime: baseDate.add(const Duration(hours: 9, minutes: 45)),
      durationMinutes: 105,
      priceEtb: 350.0,
      availableSeats: 19,
      totalSeats: 49,
      amenities: const ['AC', 'WiFi'],
    ),
    Trip(
      id: 'trip_105',
      operatorName: 'Oda Bus',
      operatorRating: 4.5,
      busModel: 'Yutong Standard',
      originCity: origin ?? 'Addis Ababa',
      destinationCity: destination ?? 'Gondar',
      departureTerminal: 'Asko Central Terminal',
      arrivalTerminal: 'Gondar Bus Station',
      departureTime: baseDate.add(const Duration(hours: 6, minutes: 15)),
      arrivalTime: baseDate.add(const Duration(hours: 16, minutes: 30)),
      durationMinutes: 615,
      priceEtb: 1450.0,
      availableSeats: 5,
      totalSeats: 49,
      amenities: const ['AC', 'USB Charger', 'Bottled Water'],
    ),
  ];

  return allTrips;
}
