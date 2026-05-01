import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/operator_models.dart';
import '../providers/operator_provider.dart';

class OperatorDashboardScreen extends ConsumerWidget {
  const OperatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(operatorOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Operator Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Analytics',
            onPressed: () => ref.refresh(operatorOverviewProvider),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Boarding Pass',
            onPressed: () => context.push(RoutePaths.operatorScan),
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const AppLoadingWidget(message: 'Loading fleet analytics...'),
        error: (err, _) => AppErrorWidget(
          message: 'Unable to load operator data: $err',
          onRetry: () => ref.refresh(operatorOverviewProvider),
        ),
        data: (overview) => _DashboardContent(overview: overview),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.overview});

  final OperatorOverview overview;

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operator Header Banner
          AppCard(
            backgroundColor: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus_filled,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              overview.operatorName,
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (overview.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppColors.primary, size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayStr,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OPERATOR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Scan Boarding Pass CTA Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF007A3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Boarding Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan digital tickets & verify passengers instantly',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push(RoutePaths.operatorScan),
                  child: const Text('Scan Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          Text(
            'Operational Overview',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                title: 'Active Trips',
                value: overview.activeTripsToday.toString(),
                subtitle: '${overview.totalBuses} buses in fleet',
                icon: Icons.directions_bus,
                color: AppColors.primary,
              ),
              _MetricCard(
                title: 'Passengers',
                value: '${overview.totalPassengersBoarded}/${overview.totalPassengersBooked}',
                subtitle: 'Boarded / Booked',
                icon: Icons.people,
                color: AppColors.secondary,
              ),
              _MetricCard(
                title: 'Fleet Occupancy',
                value: '${overview.occupancyRatePercent}%',
                subtitle: 'Average load factor',
                icon: Icons.event_seat,
                color: const Color(0xFF2E7D32),
              ),
              _MetricCard(
                title: 'Trip Revenue',
                value: '${overview.totalRevenueEtb.toInt()} ETB',
                subtitle: 'Total ticket sales',
                icon: Icons.payments,
                color: const Color(0xFFE65100),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scheduled Trips Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scheduled Trips (${overview.trips.length})',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Tap for Manifest',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (overview.trips.isEmpty)
            const AppEmptyWidget(message: 'No scheduled trips found for this operator.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overview.trips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = overview.trips[index];
                return _TripItemCard(trip: trip);
              },
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripItemCard extends StatelessWidget {
  const _TripItemCard({required this.trip});

  final OperatorTrip trip;

  @override
  Widget build(BuildContext context) {
    final depStr = DateFormat('h:mm a').format(trip.departureTime);
    final ratio = trip.totalSeats > 0 ? (trip.bookedSeats / trip.totalSeats) : 0.0;

    return AppCard(
      onTap: () {
        context.push('${RoutePaths.operatorManifest}/${trip.tripId}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.route,
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.status == 'BOARDING'
                      ? Colors.green.shade100
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: trip.status == 'BOARDING' ? Colors.green.shade800 : Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Departs $depStr',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.directions_bus_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                trip.plateNumber,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Occupancy progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Occupancy: ${trip.bookedSeats}/${trip.totalSeats} booked (${trip.occupancyRate.toInt()}%)',
                style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${trip.boardedPassengers} Boarded',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio >= 0.9 ? Colors.red : (ratio >= 0.7 ? AppColors.secondary : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.list_alt, size: 16),
                label: const Text('Manifest'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  context.push('${RoutePaths.operatorManifest}/${trip.tripId}');
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: const Text('Scan QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  context.push(RoutePaths.operatorScan);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
