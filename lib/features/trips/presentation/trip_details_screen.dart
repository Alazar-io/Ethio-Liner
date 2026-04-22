import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/data/mock_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context) {
    // Find trip by ID or fallback to default
    final trips = getMockTrips();
    final trip = trips.firstWhere(
      (t) => t.id == tripId,
      orElse: () => trips.first,
    );

    final depTimeStr = DateFormat('h:mm a, EEE MMM d').format(trip.departureTime);
    final arrTimeStr = DateFormat('h:mm a, EEE MMM d').format(trip.arrivalTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operator Header Card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.operatorName,
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${trip.operatorRating} Rating',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Verified Operator',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route & Terminal Timeline Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route & Terminals', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Departure
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.trip_origin, color: AppColors.primary, size: 20),
                          Container(width: 2, height: 40, color: AppColors.border),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Departure', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                            Text(trip.originCity, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(trip.departureTerminal, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            Text(depTimeStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Duration Badge
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Duration: ${trip.formattedDuration}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),

                  // Arrival
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arrival', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                            Text(trip.destinationCity, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(trip.arrivalTerminal, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            Text(arrTimeStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bus Specification & Amenities Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bus Amenities & Info', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Bus Model: ${trip.busModel}', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: trip.amenities.map((amenity) {
                      IconData iconData = Icons.star;
                      if (amenity.contains('WiFi')) iconData = Icons.wifi;
                      if (amenity.contains('Air') || amenity.contains('AC')) iconData = Icons.ac_unit;
                      if (amenity.contains('Charger') || amenity.contains('USB')) iconData = Icons.usb;
                      if (amenity.contains('Water')) iconData = Icons.local_drink;
                      if (amenity.contains('TV')) iconData = Icons.tv;

                      return Chip(
                        avatar: Icon(iconData, size: 16, color: AppColors.primary),
                        label: Text(amenity, style: AppTextStyles.labelMedium),
                        backgroundColor: AppColors.surfaceVariant,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Summary Card
            AppCard(
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price per passenger', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      Text('${trip.priceEtb.toInt()} ETB', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Available Seats', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      Text('${trip.availableSeats} of ${trip.totalSeats}', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Seats CTA
            AppButton(
              text: 'Select Seats (${trip.priceEtb.toInt()} ETB)',
              icon: Icons.event_seat,
              onPressed: () {
                context.push('/trips/${trip.id}/seats');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
