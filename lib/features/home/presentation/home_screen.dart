import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routing/app_router.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/models/trip_models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late City _origin;
  late City _destination;
  late DateTime _selectedDate;
  int _passengerCount = 1;

  @override
  void initState() {
    super.initState();
    _origin = ethiopianCities.firstWhere((c) => c.id == 'addis_ababa');
    _destination = ethiopianCities.firstWhere((c) => c.id == 'hawassa');
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  void _swapCities() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCityPicker({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOrigin ? 'Select Origin City' : 'Select Destination City',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: ethiopianCities.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final city = ethiopianCities[index];
                    return ListTile(
                      leading: const Icon(Icons.location_city, color: AppColors.primary),
                      title: Text(city.name, style: AppTextStyles.bodyLarge),
                      subtitle: Text('${city.region} ${city.amharicName != null ? "• ${city.amharicName}" : ""}'),
                      trailing: city.isPopular
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Popular', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          if (isOrigin) {
                            _origin = city;
                          } else {
                            _destination = city;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSearch() {
    final queryUri = Uri(
      path: RoutePaths.searchResults,
      queryParameters: {
        'origin': _origin.name,
        'destination': _destination.name,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'passengers': _passengerCount.toString(),
      },
    );
    context.push(queryUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'እንኳን ደህና መጡ! 👋',
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'EthioLiner',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Form Card (Overlapping header)
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  elevation: 2,
                  child: Column(
                    children: [
                      // Origin & Destination Row
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showCityPicker(isOrigin: true),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.trip_origin, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('From', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                                          Text(_origin.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showCityPicker(isOrigin: false),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('To', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                                          Text(_destination.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 16,
                            child: IconButton(
                              onPressed: _swapCities,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date & Passenger Count
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Travel Date', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                                        Text(
                                          DateFormat('E, MMM d').format(_selectedDate),
                                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Passengers', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                                      Text('$_passengerCount Seat${_passengerCount > 1 ? "s" : ""}',
                                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (_passengerCount > 1) {
                                            setState(() => _passengerCount--);
                                          }
                                        },
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.border,
                                          child: Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          if (_passengerCount < 6) {
                                            setState(() => _passengerCount++);
                                          }
                                        },
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.primary,
                                          child: Icon(Icons.add, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search Button
                      AppButton(
                        text: 'Search Trips',
                        icon: Icons.search,
                        onPressed: _onSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Popular Destinations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Destinations',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ethiopianCities.where((c) => c.isPopular).length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final city = ethiopianCities.where((c) => c.isPopular).toList()[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _destination = city;
                            });
                          },
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_city, color: AppColors.primary, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    city.name,
                                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    city.region,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
