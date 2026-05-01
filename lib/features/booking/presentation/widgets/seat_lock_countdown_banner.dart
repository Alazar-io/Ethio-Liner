import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../providers/booking_provider.dart';

/// Live countdown banner showing remaining temporary seat lock duration.
class SeatLockCountdownBanner extends ConsumerWidget {
  const SeatLockCountdownBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingDraftProvider);

    if (bookingState.selectedSeats.isEmpty) {
      return const SizedBox.shrink();
    }

    final isUrgent = bookingState.remainingLockSeconds < 120; // under 2 minutes
    final bannerColor = isUrgent ? Colors.red.shade50 : AppColors.primary.withValues(alpha: 0.08);
    final borderColor = isUrgent ? Colors.red.shade300 : AppColors.primary.withValues(alpha: 0.25);
    final textColor = isUrgent ? AppColors.error : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(
                'Seats locked temporarily',
                style: AppTextStyles.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bookingState.formattedCountdown,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
