import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/seat_model.dart';
import '../providers/booking_provider.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  const SeatSelectionScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  ConsumerState<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trips = getMockTrips();
      final trip = trips.firstWhere(
        (t) => t.id == widget.tripId,
        orElse: () => trips.first,
      );
      ref.read(bookingDraftProvider.notifier).initializeForTrip(trip);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingDraftProvider);
    final trip = bookingState.trip;

    if (trip == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Select Seats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${trip.originCity} → ${trip.destinationCity}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seat Legend
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Available', Colors.white, AppColors.border),
                _buildLegendItem('Selected', AppColors.primary, AppColors.primary),
                _buildLegendItem('Occupied', Colors.grey.shade400, Colors.grey.shade400),
              ],
            ),
          ),
          const Divider(height: 1),

          // Bus Seat Map Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Driver Cabin Front Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.airline_seat_recline_normal, color: AppColors.textSecondary, size: 22),
                            const SizedBox(width: 4),
                            Text('Driver', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.door_front_door_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Entrance Door', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight, thickness: 1.5),
                    const SizedBox(height: 16),

                    // Seats Grid (Rows)
                    ...List.generate(12, (rowIndex) {
                      final rowNum = rowIndex + 1;
                      final rowSeats = bookingState.seats.where((s) => s.row == rowNum).toList();

                      final seatA = rowSeats.where((s) => s.seatNumber.endsWith('A')).firstOrNull;
                      final seatB = rowSeats.where((s) => s.seatNumber.endsWith('B')).firstOrNull;
                      final seatC = rowSeats.where((s) => s.seatNumber.endsWith('C')).firstOrNull;
                      final seatD = rowSeats.where((s) => s.seatNumber.endsWith('D')).firstOrNull;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left 2 seats
                            Row(
                              children: [
                                if (seatA != null) _buildSeatWidget(seatA),
                                const SizedBox(width: 8),
                                if (seatB != null) _buildSeatWidget(seatB),
                              ],
                            ),

                            // Center Aisle with row number
                            Container(
                              width: 32,
                              alignment: Alignment.center,
                              child: Text(
                                '$rowNum',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
                              ),
                            ),

                            // Right 2 seats
                            Row(
                              children: [
                                if (seatC != null) _buildSeatWidget(seatC),
                                const SizedBox(width: 8),
                                if (seatD != null) _buildSeatWidget(seatD),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Seats (${bookingState.selectedSeats.length})',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bookingState.selectedSeats.isEmpty
                                ? 'None selected'
                                : bookingState.selectedSeats.join(', '),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${bookingState.totalPriceEtb.toInt()} ETB',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: bookingState.selectedSeats.isEmpty
                        ? 'Select at least 1 seat'
                        : 'Continue to Passenger Details',
                    onPressed: bookingState.selectedSeats.isEmpty
                        ? null
                        : () {
                            context.push(RoutePaths.passengerDetails);
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatWidget(BusSeat seat) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (seat.state) {
      case SeatState.available:
        bgColor = Colors.white;
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
        break;
      case SeatState.selected:
        bgColor = AppColors.primary;
        borderColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case SeatState.occupied:
      case SeatState.unavailable:
        bgColor = Colors.grey.shade300;
        borderColor = Colors.grey.shade400;
        textColor = Colors.grey.shade600;
        break;
    }

    final isClickable = seat.state != SeatState.occupied && seat.state != SeatState.unavailable;

    return GestureDetector(
      onTap: isClickable
          ? () {
              ref.read(bookingDraftProvider.notifier).toggleSeat(seat.seatNumber);
            }
          : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          seat.seatNumber,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
