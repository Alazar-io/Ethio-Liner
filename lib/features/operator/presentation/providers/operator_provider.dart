import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/features/auth/presentation/providers/auth_provider.dart';
import '../../data/operator_repository.dart';
import '../../domain/models/operator_models.dart';

/// Provider for OperatorRepository.
final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiOperatorRepository(apiClient: apiClient);
});

/// Provider for operator dashboard overview.
final operatorOverviewProvider = FutureProvider.autoDispose<OperatorOverview>((ref) async {
  final repo = ref.watch(operatorRepositoryProvider);
  return await repo.getOverview();
});

/// State for the Trip Manifest screen.
class TripManifestState {
  const TripManifestState({
    this.manifest,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final TripManifest? manifest;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  List<ManifestPassenger> get filteredPassengers {
    if (manifest == null) return [];
    if (searchQuery.trim().isEmpty) return manifest!.passengers;
    final q = searchQuery.toLowerCase().trim();
    return manifest!.passengers.where((p) {
      return p.passengerName.toLowerCase().contains(q) ||
          p.seatNumber.toLowerCase().contains(q) ||
          p.phoneNumber.contains(q) ||
          p.ticketId.toLowerCase().contains(q);
    }).toList();
  }

  TripManifestState copyWith({
    TripManifest? manifest,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TripManifestState(
      manifest: manifest ?? this.manifest,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing passenger manifest for a trip.
class TripManifestNotifier extends StateNotifier<TripManifestState> {
  TripManifestNotifier(this._repository, this.tripId) : super(const TripManifestState(isLoading: true)) {
    loadManifest();
  }

  final OperatorRepository _repository;
  final int tripId;

  Future<void> loadManifest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final manifest = await _repository.getTripManifest(tripId);
      state = state.copyWith(manifest: manifest, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> toggleBoarding(String ticketRef) async {
    if (state.manifest == null) return;
    try {
      final updatedPassenger = await _repository.togglePassengerBoarded(ticketRef);
      final updatedPassengers = state.manifest!.passengers.map((p) {
        if (p.ticketId == ticketRef) {
          return updatedPassenger;
        }
        return p;
      }).toList();

      final boardedCount = updatedPassengers.where((p) => p.isBoarded).length;
      final updatedManifest = TripManifest(
        tripId: state.manifest!.tripId,
        route: state.manifest!.route,
        originCity: state.manifest!.originCity,
        destinationCity: state.manifest!.destinationCity,
        departureTime: state.manifest!.departureTime,
        departureTerminal: state.manifest!.departureTerminal,
        arrivalTerminal: state.manifest!.arrivalTerminal,
        busModel: state.manifest!.busModel,
        plateNumber: state.manifest!.plateNumber,
        totalCapacity: state.manifest!.totalCapacity,
        totalBooked: state.manifest!.totalBooked,
        totalBoarded: boardedCount,
        passengers: updatedPassengers,
      );

      state = state.copyWith(manifest: updatedManifest);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not toggle boarding status.');
    }
  }
}

/// Provider for trip manifest with parameter tripId.
final tripManifestProvider = StateNotifierProvider.autoDispose.family<TripManifestNotifier, TripManifestState, int>(
  (ref, tripId) {
    final repo = ref.watch(operatorRepositoryProvider);
    return TripManifestNotifier(repo, tripId);
  },
);

/// State for the QR Boarding Scanner.
class QrBoardingState {
  const QrBoardingState({
    this.isScanning = true,
    this.isProcessing = false,
    this.lastResult,
    this.selectedTripId,
  });

  final bool isScanning;
  final bool isProcessing;
  final BoardingValidationResult? lastResult;
  final int? selectedTripId;

  QrBoardingState copyWith({
    bool? isScanning,
    bool? isProcessing,
    BoardingValidationResult? lastResult,
    int? selectedTripId,
  }) {
    return QrBoardingState(
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      lastResult: lastResult ?? this.lastResult,
      selectedTripId: selectedTripId ?? this.selectedTripId,
    );
  }
}

/// Notifier managing QR ticket scanning and verification.
class QrBoardingNotifier extends StateNotifier<QrBoardingState> {
  QrBoardingNotifier(this._repository) : super(const QrBoardingState());

  final OperatorRepository _repository;

  void setSelectedTripId(int? tripId) {
    state = state.copyWith(selectedTripId: tripId);
  }

  void resetScanner() {
    state = state.copyWith(
      isScanning: true,
      isProcessing: false,
      lastResult: null,
    );
  }

  Future<BoardingValidationResult> validateAndBoard(String rawQrData) async {
    state = state.copyWith(isProcessing: true, isScanning: false);
    try {
      final result = await _repository.validateAndBoard(
        qrData: rawQrData,
        tripId: state.selectedTripId,
      );
      state = state.copyWith(
        isProcessing: false,
        lastResult: result,
      );
      return result;
    } catch (e) {
      const fallbackResult = BoardingValidationResult(
        status: BoardingStatus.invalid,
        message: 'Network error verifying ticket. Please retry.',
        canBoard: false,
      );
      state = state.copyWith(
        isProcessing: false,
        lastResult: fallbackResult,
      );
      return fallbackResult;
    }
  }
}

/// Provider for QR Boarding Scanner.
final qrBoardingProvider = StateNotifierProvider.autoDispose<QrBoardingNotifier, QrBoardingState>((ref) {
  final repo = ref.watch(operatorRepositoryProvider);
  return QrBoardingNotifier(repo);
});
