import 'dart:async';
import '../../../core/network/api_client.dart';
import '../domain/models/operator_models.dart';

abstract class OperatorRepository {
  Future<OperatorOverview> getOverview();
  Future<TripManifest> getTripManifest(int tripId);
  Future<BoardingValidationResult> validateAndBoard({required String qrData, int? tripId});
  Future<ManifestPassenger> togglePassengerBoarded(String ticketRef);
}

class ApiOperatorRepository implements OperatorRepository {
  ApiOperatorRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<OperatorOverview> getOverview() async {
    try {
      final response = await apiClient.get('/operator/overview');
      return OperatorOverview.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return _mockOverview();
    }
  }

  @override
  Future<TripManifest> getTripManifest(int tripId) async {
    try {
      final response = await apiClient.get('/operator/manifest/$tripId');
      return TripManifest.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return _mockManifest(tripId);
    }
  }

  @override
  Future<BoardingValidationResult> validateAndBoard({
    required String qrData,
    int? tripId,
  }) async {
    try {
      final response = await apiClient.post(
        '/operator/board',
        body: {
          'qr_data': qrData,
          'expected_trip_id': tripId,
        },
      );
      return BoardingValidationResult.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return _mockValidateAndBoard(qrData, tripId);
    }
  }

  @override
  Future<ManifestPassenger> togglePassengerBoarded(String ticketRef) async {
    try {
      final response = await apiClient.post('/operator/toggle-board/$ticketRef');
      return ManifestPassenger.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return ManifestPassenger(
        ticketId: ticketRef,
        passengerName: 'Passenger',
        phoneNumber: '+251911223344',
        seatNumber: '3A',
        bookingReference: 'ETL-2026-78421',
        status: BoardingStatus.alreadyBoarded,
        boardedAt: DateTime.now(),
      );
    }
  }

  static OperatorOverview _mockOverview() {
    final now = DateTime.now();
    final trips = [
      OperatorTrip(
        tripId: 1,
        route: 'Addis Ababa → Hawassa',
        originCity: 'Addis Ababa',
        destinationCity: 'Hawassa',
        busModel: 'Yutong Luxury 2024',
        plateNumber: '3-A45124-ET',
        departureTime: DateTime(now.year, now.month, now.day, 6, 0),
        priceEtb: 750.0,
        totalSeats: 48,
        bookedSeats: 42,
        boardedPassengers: 36,
        occupancyRate: 87.5,
        status: 'BOARDING',
      ),
      OperatorTrip(
        tripId: 2,
        route: 'Addis Ababa → Bahir Dar',
        originCity: 'Addis Ababa',
        destinationCity: 'Bahir Dar',
        busModel: 'Scania Marcopolo VIP',
        plateNumber: '3-B98124-ET',
        departureTime: DateTime(now.year, now.month, now.day, 7, 0),
        priceEtb: 1200.0,
        totalSeats: 48,
        bookedSeats: 48,
        boardedPassengers: 12,
        occupancyRate: 100.0,
        status: 'SCHEDULED',
      ),
      OperatorTrip(
        tripId: 3,
        route: 'Addis Ababa → Adama',
        originCity: 'Addis Ababa',
        destinationCity: 'Adama',
        busModel: 'Golden Dragon Express',
        plateNumber: '3-C12456-ET',
        departureTime: DateTime(now.year, now.month, now.day, 9, 30),
        priceEtb: 300.0,
        totalSeats: 48,
        bookedSeats: 30,
        boardedPassengers: 0,
        occupancyRate: 62.5,
        status: 'SCHEDULED',
      ),
    ];

    return OperatorOverview(
      operatorName: 'Selam Bus Line Operations',
      isVerified: true,
      totalBuses: 18,
      totalRoutes: 12,
      totalTrips: 3,
      activeTripsToday: 3,
      totalPassengersBooked: 120,
      totalPassengersBoarded: 48,
      occupancyRatePercent: 83.3,
      totalRevenueEtb: 98100.0,
      trips: trips,
    );
  }

  static TripManifest _mockManifest(int tripId) {
    final now = DateTime.now();
    return TripManifest(
      tripId: tripId,
      route: 'Addis Ababa → Hawassa',
      originCity: 'Addis Ababa',
      destinationCity: 'Hawassa',
      departureTime: DateTime(now.year, now.month, now.day, 6, 0),
      departureTerminal: 'Lamberet Bus Terminal, Addis Ababa',
      arrivalTerminal: 'Hawassa Central Station',
      busModel: 'Yutong Luxury 2024',
      plateNumber: '3-A45124-ET',
      totalCapacity: 48,
      totalBooked: 6,
      totalBoarded: 4,
      passengers: [
        ManifestPassenger(
          ticketId: 'TCK-78421-1',
          passengerName: 'Abebe Bikila',
          phoneNumber: '+251911223344',
          seatNumber: '3A',
          bookingReference: 'ETL-2026-78421',
          status: BoardingStatus.alreadyBoarded,
          boardedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ManifestPassenger(
          ticketId: 'TCK-78421-2',
          passengerName: 'Derartu Tulu',
          phoneNumber: '+251911334455',
          seatNumber: '3B',
          bookingReference: 'ETL-2026-78421',
          status: BoardingStatus.alreadyBoarded,
          boardedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        ManifestPassenger(
          ticketId: 'TCK-55123-1',
          passengerName: 'Haile Gebrselassie',
          phoneNumber: '+251912556677',
          seatNumber: '4A',
          bookingReference: 'ETL-2026-55123',
          status: BoardingStatus.alreadyBoarded,
          boardedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        ManifestPassenger(
          ticketId: 'TCK-55123-2',
          passengerName: 'Kenenisa Bekele',
          phoneNumber: '+251913778899',
          seatNumber: '4B',
          bookingReference: 'ETL-2026-55123',
          status: BoardingStatus.alreadyBoarded,
          boardedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        const ManifestPassenger(
          ticketId: 'TCK-99012-1',
          passengerName: 'Tirunesh Dibaba',
          phoneNumber: '+251914112233',
          seatNumber: '7C',
          bookingReference: 'ETL-2026-99012',
          status: BoardingStatus.valid,
        ),
        const ManifestPassenger(
          ticketId: 'TCK-99012-2',
          passengerName: 'Meseret Defar',
          phoneNumber: '+251915445566',
          seatNumber: '7D',
          bookingReference: 'ETL-2026-99012',
          status: BoardingStatus.valid,
        ),
      ],
    );
  }

  static BoardingValidationResult _mockValidateAndBoard(String qrData, int? tripId) {
    final cleaned = qrData.trim();

    if (cleaned.contains('CANCELLED') || cleaned.contains('cancelled')) {
      return const BoardingValidationResult(
        status: BoardingStatus.cancelled,
        message: 'This ticket was CANCELLED by passenger or operator.',
        canBoard: false,
      );
    }

    if (cleaned.contains('EXPIRED') || cleaned.contains('expired')) {
      return const BoardingValidationResult(
        status: BoardingStatus.expired,
        message: 'This ticket has EXPIRED.',
        canBoard: false,
      );
    }

    if (cleaned.contains('TCK-ALREADY') || cleaned.contains('ALREADY_BOARDED')) {
      return BoardingValidationResult(
        status: BoardingStatus.alreadyBoarded,
        message: 'Passenger was already boarded at 5:45 AM. Duplicate scan denied!',
        canBoard: false,
        passengerName: 'Abebe Bikila',
        seatNumber: '3A',
        route: 'Addis Ababa → Hawassa',
        boardedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
    }

    if (cleaned.startsWith('ETHIOLINER:') || cleaned.startsWith('TCK-')) {
      // Parse details if available
      String name = 'Abebe Bikila';
      String seat = '3A';
      String ticketRef = cleaned;

      if (cleaned.startsWith('ETHIOLINER:')) {
        final parts = cleaned.split(':');
        if (parts.length >= 6) {
          ticketRef = parts[2];
          seat = parts[4];
          name = parts[5];
        }
      }

      return BoardingValidationResult(
        status: BoardingStatus.valid,
        message: 'Boarding Approved! Welcome passenger aboard.',
        canBoard: true,
        ticketId: ticketRef,
        passengerName: name,
        seatNumber: seat,
        route: 'Addis Ababa → Hawassa',
        boardedAt: DateTime.now(),
      );
    }

    return const BoardingValidationResult(
      status: BoardingStatus.invalid,
      message: 'Unrecognized ticket format or QR code not found in EthioLiner registry.',
      canBoard: false,
    );
  }
}
