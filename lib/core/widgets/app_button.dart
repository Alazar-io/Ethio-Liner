import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Button variants supported by [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

/// Reusable button widget for EthioLiner.
///
/// Supports primary, secondary, outlined, and text variants with
/// optional leading icon and loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = 52.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.outlined ||
                      variant == AppButtonVariant.text
                  ? theme.colorScheme.primary
                  : AppColors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAlignment: MainAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: AppTextStyles.labelLarge,
          ),
          child: child,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: AppTextStyles.labelLarge,
          ),
          child: child,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: AppTextStyles.labelLarge,
          ),
          child: child,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            textStyle: AppTextStyles.labelLarge,
          ),
          child: child,
        );
        break;
    }

    return button;
  }
}
