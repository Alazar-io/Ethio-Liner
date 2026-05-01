import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/operator_models.dart';
import '../providers/operator_provider.dart';

class PassengerManifestScreen extends ConsumerWidget {
  const PassengerManifestScreen({
    super.key,
    required this.tripId,
  });

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifestState = ref.watch(tripManifestProvider(tripId));
    final notifier = ref.read(tripManifestProvider(tripId).notifier);

    if (manifestState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passenger Manifest')),
        body: const AppLoadingWidget(message: 'Loading verified passenger manifest...'),
      );
    }

    final manifest = manifestState.manifest;
    if (manifest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passenger Manifest')),
        body: Center(
          child: Text(manifestState.errorMessage ?? 'No manifest data available for this trip.'),
        ),
      );
    }

    final depStr = DateFormat('h:mm a, EEE MMM d').format(manifest.departureTime);
    final passengers = manifestState.filteredPassengers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Passenger Manifest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(manifest.route, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Open QR Scanner',
            onPressed: () => context.push(RoutePaths.operatorScan),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Manifest',
            onPressed: () => notifier.loadManifest(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip Details Header Card
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      manifest.route,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        manifest.plateNumber,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Departure: $depStr • ${manifest.departureTerminal}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // Manifest Counters Strip
                Row(
                  children: [
                    _ManifestCounter(
                      label: 'Booked',
                      count: manifest.totalBooked,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _ManifestCounter(
                      label: 'Boarded',
                      count: manifest.totalBoarded,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 8),
                    _ManifestCounter(
                      label: 'Remaining',
                      count: manifest.remainingToBoard,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _ManifestCounter(
                      label: 'Capacity',
                      count: manifest.totalCapacity,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search / Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by passenger name, seat (e.g. 3A), or phone...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: manifestState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => notifier.updateSearchQuery(''),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: notifier.updateSearchQuery,
            ),
          ),

          // Passenger List
          Expanded(
            child: passengers.isEmpty
                ? const AppEmptyWidget(
                    message: 'No passengers found matching your search filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: passengers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = passengers[index];
                      return _PassengerManifestTile(
                        passenger: p,
                        onToggleBoard: () => notifier.toggleBoarding(p.ticketId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ManifestCounter extends StatelessWidget {
  const _ManifestCounter({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerManifestTile extends StatelessWidget {
  const _PassengerManifestTile({
    required this.passenger,
    required this.onToggleBoard,
  });

  final ManifestPassenger passenger;
  final VoidCallback onToggleBoard;

  @override
  Widget build(BuildContext context) {
    final isBoarded = passenger.isBoarded;

    return AppCard(
      child: Row(
        children: [
          // Seat Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isBoarded
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBoarded ? const Color(0xFF2E7D32) : AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                passenger.seatNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isBoarded ? const Color(0xFF2E7D32) : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Passenger Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger.passengerName,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${passenger.phoneNumber} • ${passenger.ticketId}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                if (passenger.boardedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Boarded at ${DateFormat('h:mm a').format(passenger.boardedAt!)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),

          // Boarding status & manual toggle button
          IconButton(
            icon: Icon(
              isBoarded ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isBoarded ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: 28,
            ),
            tooltip: isBoarded ? 'Mark Unboarded' : 'Check In Passenger',
            onPressed: onToggleBoard,
          ),
        ],
      ),
    );
  }
}
