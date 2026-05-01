import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/seat_lock_countdown_banner.dart';

class PassengerDetailsScreen extends ConsumerStatefulWidget {
  const PassengerDetailsScreen({super.key});

  @override
  ConsumerState<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends ConsumerState<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _emailControllers = [];

  @override
  void initState() {
    super.initState();
    final selectedSeats = ref.read(bookingDraftProvider).selectedSeats;
    for (int i = 0; i < selectedSeats.length; i++) {
      _nameControllers.add(TextEditingController());
      _phoneControllers.add(TextEditingController(text: i == 0 ? '+251' : ''));
      _emailControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _phoneControllers) {
      c.dispose();
    }
    for (final c in _emailControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedSeats = ref.read(bookingDraftProvider).selectedSeats;
      final List<Passenger> passengers = [];

      for (int i = 0; i < selectedSeats.length; i++) {
        passengers.add(
          Passenger(
            fullName: _nameControllers[i].text.trim(),
            phoneNumber: _phoneControllers[i].text.trim(),
            email: _emailControllers[i].text.trim().isNotEmpty
                ? _emailControllers[i].text.trim()
                : null,
            assignedSeat: selectedSeats[i],
          ),
        );
      }

      ref.read(bookingDraftProvider.notifier).setPassengers(passengers);
      context.push(RoutePaths.bookingSummary);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BookingDraftState>(bookingDraftProvider, (previous, next) {
      if (next.isLockExpired && !(previous?.isLockExpired ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Reservation Expired'),
            content: const Text(
              'Your temporary seat hold has expired. The seats have been released for other passengers. Please select your seats again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
                child: const Text('Select Seats Again'),
              ),
            ],
          ),
        );
      }
    });

    final bookingState = ref.watch(bookingDraftProvider);
    final selectedSeats = bookingState.selectedSeats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Passenger Details'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SeatLockCountdownBanner(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: selectedSeats.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final seatNum = selectedSeats[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Passenger ${index + 1}',
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Seat $seatNum',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        AppTextField(
                          controller: _nameControllers[index],
                          label: 'Full Name (as on Kebele ID / Passport)',
                          hint: 'e.g. Abebe Bikila',
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 12),

                        // Ethiopian Phone Number
                        AppTextField(
                          controller: _phoneControllers[index],
                          label: 'Phone Number',
                          hint: '+251911223344 or 0911223344',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.validateEthiopianPhone,
                        ),
                        const SizedBox(height: 12),

                        // Email Address (Optional for additional passengers)
                        AppTextField(
                          controller: _emailControllers[index],
                          label: index == 0 ? 'Email Address (for Digital Ticket)' : 'Email Address (Optional)',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: index == 0
                              ? Validators.validateEmail
                              : (val) {
                                  if (val != null && val.trim().isNotEmpty) {
                                    return Validators.validateEmail(val);
                                  }
                                  return null;
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Submit Button
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
                child: AppButton(
                  text: 'Continue to Booking Summary',
                  onPressed: _onContinue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
