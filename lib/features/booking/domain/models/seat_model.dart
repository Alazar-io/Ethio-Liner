import 'package:equatable/equatable.dart';

/// State of an individual bus seat.
enum SeatState {
  available,
  selected,
  occupied,
  unavailable,
}

/// Representation of a bus seat in the interactive seat map.
class BusSeat extends Equatable {
  const BusSeat({
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.isAisle,
    required this.state,
    required this.priceEtb,
  });

  final String seatNumber; // e.g. "1A", "1B", "1C", "1D"
  final int row;
  final int column; // 0, 1 = left side; 2 = aisle; 3, 4 = right side
  final bool isAisle;
  final SeatState state;
  final double priceEtb;

  BusSeat copyWith({
    String? seatNumber,
    int? row,
    int? column,
    bool? isAisle,
    SeatState? state,
    double? priceEtb,
  }) {
    return BusSeat(
      seatNumber: seatNumber ?? this.seatNumber,
      row: row ?? this.row,
      column: column ?? this.column,
      isAisle: isAisle ?? this.isAisle,
      state: state ?? this.state,
      priceEtb: priceEtb ?? this.priceEtb,
    );
  }

  @override
  List<Object?> get props => [seatNumber, row, column, isAisle, state, priceEtb];
}

/// Generates a standard 2x2 Ethiopian intercity bus layout (approx 45-49 seats).
List<BusSeat> generateBusSeatLayout({
  required double basePriceEtb,
  int totalRows = 12,
  List<String> occupiedSeatNumbers = const ['2A', '2B', '5C', '6D', '9A', '10B', '11C'],
}) {
  final List<BusSeat> seats = [];

  for (int r = 1; r <= totalRows; r++) {
    // 2 seats on left: A, B
    final seatA = '${r}A';
    final seatB = '${r}B';
    seats.add(
      BusSeat(
        seatNumber: seatA,
        row: r,
        column: 0,
        isAisle: false,
        state: occupiedSeatNumbers.contains(seatA) ? SeatState.occupied : SeatState.available,
        priceEtb: basePriceEtb,
      ),
    );
    seats.add(
      BusSeat(
        seatNumber: seatB,
        row: r,
        column: 1,
        isAisle: false,
        state: occupiedSeatNumbers.contains(seatB) ? SeatState.occupied : SeatState.available,
        priceEtb: basePriceEtb,
      ),
    );

    // 2 seats on right: C, D
    final seatC = '${r}C';
    final seatD = '${r}D';
    seats.add(
      BusSeat(
        seatNumber: seatC,
        row: r,
        column: 3,
        isAisle: false,
        state: occupiedSeatNumbers.contains(seatC) ? SeatState.occupied : SeatState.available,
        priceEtb: basePriceEtb,
      ),
    );
    seats.add(
      BusSeat(
        seatNumber: seatD,
        row: r,
        column: 4,
        isAisle: false,
        state: occupiedSeatNumbers.contains(seatD) ? SeatState.occupied : SeatState.available,
        priceEtb: basePriceEtb,
      ),
    );
  }

  return seats;
}
