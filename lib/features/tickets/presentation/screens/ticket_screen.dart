import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../core/utils/ethiopian_calendar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/qr_code_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../booking/domain/models/booking_model.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class TicketScreen extends ConsumerWidget {
  const TicketScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(myTripsProvider);

    // Locate ticket across all bookings
    DigitalTicket? foundTicket;
    for (final b in allBookings) {
      for (final t in b.tickets) {
        if (t.ticketId == ticketId) {
          foundTicket = t;
          break;
        }
      }
      if (foundTicket != null) break;
    }

    if (foundTicket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Digital Ticket')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Ticket Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              AppButton(
                text: 'Go to My Trips',
                fullWidth: false,
                onPressed: () => context.go(RoutePaths.myTrips),
              ),
            ],
          ),
        ),
      );
    }

    final ticket = foundTicket;
    final trip = ticket.trip;
    final activeLocale = ref.watch(localeProvider);
    final ethDate = EthiopianDate.fromGregorian(trip.departureTime);
    final depTimeStr = DateFormat('h:mm a, EEE MMM d').format(trip.departureTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Digital Boarding Ticket'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(RoutePaths.myTrips),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Perforated Ticket Container
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header with Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.operatorName,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Ref: ${ticket.bookingReference}',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ticket.status == TicketStatus.valid
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket.status == TicketStatus.valid ? 'VALID TICKET' : 'CANCELLED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ticket.status == TicketStatus.valid ? AppColors.primary : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  QrCodeWidget(
                    data: ticket.qrData,
                    size: 210,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan at Bus Terminal for Boarding',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Perforated Line Decoration
                  Row(
                    children: List.generate(
                      20,
                      (index) => Expanded(
                        child: Container(
                          height: 2,
                          color: index.isEven ? AppColors.border : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Passenger & Seat Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Passenger Name', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(ticket.passengerName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Seat Number', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            ticket.seatNumber,
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

                  // Route & Departure Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Origin', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          Text(trip.originCity, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text(trip.departureTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Destination', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          Text(trip.destinationCity, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text(trip.arrivalTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Departure Timestamp
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Departure Date & Time', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(depTimeStr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              ethDate.format(activeLocale.languageCode),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Buttons
            AppButton(
              text: 'View All My Trips',
              icon: Icons.confirmation_number_outlined,
              onPressed: () => context.go(RoutePaths.myTrips),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Back to Home',
              variant: AppButtonVariant.outlined,
              icon: Icons.home,
              onPressed: () => context.go(RoutePaths.home),
            ),
          ],
        ),
      ),
    );
  }
}
