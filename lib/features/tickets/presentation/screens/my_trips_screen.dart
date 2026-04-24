import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../booking/domain/models/booking_model.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(myTripsProvider);

    final upcomingBookings = allBookings
        .where((b) => b.paymentStatus == PaymentStatus.success && b.trip.departureTime.isAfter(DateTime.now()))
        .toList();

    final completedBookings = allBookings
        .where((b) => b.paymentStatus == PaymentStatus.success && b.trip.departureTime.isBefore(DateTime.now()))
        .toList();

    final cancelledBookings = allBookings
        .where((b) => b.paymentStatus == PaymentStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Trips'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Upcoming (${upcomingBookings.length})'),
            Tab(text: 'Completed (${completedBookings.length})'),
            Tab(text: 'Cancelled (${cancelledBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripList(upcomingBookings, isUpcoming: true),
          _buildTripList(completedBookings),
          _buildTripList(cancelledBookings),
        ],
      ),
    );
  }

  Widget _buildTripList(List<Booking> bookings, {bool isUpcoming = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: AppEmptyWidget(
          message: 'No trips in this category.',
          icon: Icons.confirmation_number_outlined,
          actionLabel: isUpcoming ? 'Book a Trip' : null,
          onAction: isUpcoming ? () => context.go(RoutePaths.home) : null,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final trip = booking.trip;
        final depDateStr = DateFormat('EEE, MMM d, yyyy').format(trip.departureTime);
        final depTimeStr = DateFormat('h:mm a').format(trip.departureTime);

        return AppCard(
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
                      color: booking.paymentStatus == PaymentStatus.cancelled
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.paymentStatus == PaymentStatus.cancelled ? 'CANCELLED' : 'CONFIRMED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: booking.paymentStatus == PaymentStatus.cancelled ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        Text(trip.originCity, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(trip.departureTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('To', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        Text(trip.destinationCity, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(trip.arrivalTerminal, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(depDateStr, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                      Text('Departure: $depTimeStr', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Text(
                    'Seats: ${booking.selectedSeats.join(", ")}',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'View Digital Ticket',
                      icon: Icons.qr_code_2,
                      height: 42,
                      onPressed: () {
                        if (booking.tickets.isNotEmpty) {
                          context.push('/tickets/${booking.tickets.first.ticketId}');
                        }
                      },
                    ),
                  ),
                  if (isUpcoming && booking.paymentStatus != PaymentStatus.cancelled) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(booking);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Trip Booking?'),
          content: Text('Are you sure you want to cancel booking ${booking.bookingReference}? Your seats will be released.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep Booking'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                ref.read(myTripsProvider.notifier).cancelBooking(booking.bookingReference);
                Navigator.pop(context);
              },
              child: const Text('Yes, Cancel Trip'),
            ),
          ],
        );
      },
    );
  }
}
