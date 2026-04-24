import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';

class PaymentSimulationScreen extends ConsumerStatefulWidget {
  const PaymentSimulationScreen({super.key});

  @override
  ConsumerState<PaymentSimulationScreen> createState() => _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends ConsumerState<PaymentSimulationScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.telebirr;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    ref.read(bookingDraftProvider.notifier).setPaymentMethod(_selectedMethod);
    final success = await ref.read(bookingDraftProvider.notifier).processSimulatedPayment();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      final confirmed = ref.read(bookingDraftProvider).confirmedBooking;
      if (confirmed != null && confirmed.tickets.isNotEmpty) {
        final ticketId = confirmed.tickets.first.ticketId;
        context.go('/tickets/$ticketId');
      } else {
        context.go(RoutePaths.home);
      }
    } else {
      setState(() {
        _errorMessage = 'Simulated transaction could not be completed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingDraftProvider);
    final totalAmount = bookingState.totalPriceEtb + 25.0; // including platform fee

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Simulated Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulation notice banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demo Simulation: No real money will be charged. This demonstrates the Ethiopian booking flow.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount summary card
            AppCard(
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount Due', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      Text('${totalAmount.toInt()} ETB', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '${bookingState.selectedSeats.length} Seats Reserved',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Select Payment Method',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Payment Methods List
            ...PaymentMethod.values.map((method) {
              final isSelected = _selectedMethod == method;
              IconData methodIcon;
              Color iconColor;

              switch (method) {
                case PaymentMethod.telebirr:
                  methodIcon = Icons.phone_android;
                  iconColor = const Color(0xFF005DAA);
                  break;
                case PaymentMethod.cbeBirr:
                  methodIcon = Icons.account_balance;
                  iconColor = const Color(0xFF8B1D41);
                  break;
                case PaymentMethod.awashBirr:
                  methodIcon = Icons.account_balance_wallet;
                  iconColor = const Color(0xFF007A33);
                  break;
                case PaymentMethod.cash:
                  methodIcon = Icons.money;
                  iconColor = AppColors.primary;
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () {
                          setState(() {
                            _selectedMethod = method;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(methodIcon, color: iconColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.displayName,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method.description,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primary : AppColors.border,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Pay Button with simulated loading spinner
            AppButton(
              text: _isProcessing
                  ? 'Processing Payment...'
                  : 'Pay ${totalAmount.toInt()} ETB with ${_selectedMethod.displayName}',
              icon: Icons.check_circle_outline,
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _handlePayment,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
