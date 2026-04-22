import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/models/trip_models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

enum SortOption { priceLowToHigh, departureTime, rating }

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    this.origin,
    this.destination,
    this.dateStr,
    this.passengersStr,
  });

  final String? origin;
  final String? destination;
  final String? dateStr;
  final String? passengersStr;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  SortOption _currentSort = SortOption.departureTime;
  late List<Trip> _trips;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  void _fetchTrips() {
    setState(() => _isLoading = true);
    // Simulate minor network delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final origin = widget.origin ?? 'Addis Ababa';
        final destination = widget.destination ?? 'Hawassa';
        final rawTrips = getMockTrips(origin: origin, destination: destination);
        _applySort(rawTrips, _currentSort);
        setState(() {
          _trips = rawTrips;
          _isLoading = false;
        });
      }
    });
  }

  void _applySort(List<Trip> trips, SortOption sort) {
    switch (sort) {
      case SortOption.priceLowToHigh:
        trips.sort((a, b) => a.priceEtb.compareTo(b.priceEtb));
        break;
      case SortOption.departureTime:
        trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case SortOption.rating:
        trips.sort((a, b) => b.operatorRating.compareTo(a.operatorRating));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.origin ?? 'Addis Ababa';
    final destination = widget.destination ?? 'Hawassa';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '$origin → $destination',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.dateStr != null)
              Text(
                widget.dateStr!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Filter / Sort Bar
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_trips.length} Trips Available',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      PopupMenuButton<SortOption>(
                        initialValue: _currentSort,
                        onSelected: (sort) {
                          setState(() {
                            _currentSort = sort;
                            _applySort(_trips, sort);
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: SortOption.departureTime,
                            child: Text('Earliest Departure'),
                          ),
                          PopupMenuItem(
                            value: SortOption.priceLowToHigh,
                            child: Text('Lowest Price'),
                          ),
                          PopupMenuItem(
                            value: SortOption.rating,
                            child: Text('Top Rated Operator'),
                          ),
                        ],
                        child: Row(
                          children: [
                            const Icon(Icons.sort, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Trip List
                Expanded(
                  child: _trips.isEmpty
                      ? AppEmptyWidget(
                          message: 'No trips available for $origin to $destination.',
                          icon: Icons.directions_bus,
                          actionLabel: 'Search Different Route',
                          onAction: () => context.pop(),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _trips.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final trip = _trips[index];
                            return _TripCard(trip: trip);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final depTimeStr = DateFormat('h:mm a').format(trip.departureTime);
    final arrTimeStr = DateFormat('h:mm a').format(trip.arrivalTime);

    return AppCard(
      onTap: () {
        context.push('/trips/${trip.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operator header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.operatorName,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        trip.busModel,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      trip.operatorRating.toString(),
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Departure -> Arrival Timeline
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(depTimeStr, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(trip.originCity, style: AppTextStyles.bodyMedium),
                    Text(
                      trip.departureTerminal,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Duration Line
              Column(
                children: [
                  Text(
                    trip.formattedDuration,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      Container(width: 50, height: 2, color: AppColors.border),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(arrTimeStr, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(trip.destinationCity, style: AppTextStyles.bodyMedium),
                    Text(
                      trip.arrivalTerminal,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Price & Seats CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.priceEtb.toInt()} ETB',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${trip.availableSeats} seats left',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: trip.availableSeats < 10 ? AppColors.error : AppColors.textSecondary,
                      fontWeight: trip.availableSeats < 10 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              AppButton(
                text: 'Select Seats',
                fullWidth: false,
                height: 40,
                onPressed: () {
                  context.push('/trips/${trip.id}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
