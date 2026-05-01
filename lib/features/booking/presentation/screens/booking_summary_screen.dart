import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../providers/booking_provider.dart';
import '../widgets/seat_lock_countdown_banner.dart';

class BookingSummaryScreen extends ConsumerWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BookingDraftState>(bookingDraftProvider, (previous, next) {
      if (next.isLockExpired && !(previous?.isLockExpired ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Reservation Expired'),
            content: const Text(
              'Your temporary seat hold has expired. The seats have been released for other passengers.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go(RoutePaths.home);
                },
                child: const Text('Return to Home'),
              ),
            ],
          ),
        );
      }
    });

    final bookingState = ref.watch(bookingDraftProvider);
    final trip = bookingState.trip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Summary')),
        body: const Center(child: Text('No active booking.')),
      );
    }

    final depTimeStr = DateFormat('h:mm a, EEE MMM d').format(trip.departureTime);
    final arrTimeStr = DateFormat('h:mm a, EEE MMM d').format(trip.arrivalTime);
    final baseFare = bookingState.totalPriceEtb;
    const serviceFee = 25.0; // ETB 25 digital platform service fee
    final totalAmount = baseFare + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: Column(
        children: [
          const SeatLockCountdownBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.operatorName,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.busModel,
                          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          Text(trip.originCity, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(trip.departureTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          Text(depTimeStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('To', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          Text(trip.destinationCity, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(trip.arrivalTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          Text(arrTimeStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Passengers Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Passengers & Seats', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Edit Details'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...bookingState.passengers.map((passenger) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(passenger.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text(passenger.phoneNumber, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Seat ${passenger.assignedSeat}',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fare Breakdown Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Breakdown', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bus Fare (${bookingState.selectedSeats.length} x ${trip.priceEtb.toInt()} ETB)',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text('${baseFare.toInt()} ETB', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Platform Service Fee', style: AppTextStyles.bodyMedium),
                      Text('${serviceFee.toInt()} ETB', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '${totalAmount.toInt()} ETB',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proceed to Payment CTA
            AppButton(
              text: 'Proceed to Payment (${totalAmount.toInt()} ETB)',
              icon: Icons.payment,
              onPressed: () {
                context.push(RoutePaths.payment);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  ],
),
    );
  }
}
