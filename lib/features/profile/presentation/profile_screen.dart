import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routing/app_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activeLocale = ref.watch(localeProvider);

    String languageDisplayName = 'English';
    if (activeLocale.languageCode == 'am') {
      languageDisplayName = 'አማርኛ (Amharic)';
    } else if (activeLocale.languageCode == 'om') {
      languageDisplayName = 'Afaan Oromoo';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (user != null) ...[
              // Authenticated User Profile Card
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account Details List
              AppCard(
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone_outlined, 'Phone', user.phoneNumber),
                    const Divider(),
                    _buildInfoTile(Icons.email_outlined, 'Email', user.email),
                    const Divider(),
                    _buildInfoTile(Icons.security_outlined, 'Role', user.role.displayName),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              AppButton(
                text: 'Log Out',
                variant: AppButtonVariant.outlined,
                icon: Icons.logout,
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ] else ...[
              // Guest / Unauthenticated State
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to EthioLiner',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log in to view your bookings, access tickets offline, and manage your account.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Log In',
                      icon: Icons.login,
                      onPressed: () => context.push(RoutePaths.login),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Create an Account',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.push(RoutePaths.register),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Operator Platform Entry
            AppCard(
              onTap: () => context.push(RoutePaths.operatorDashboard),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business_center, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operator Platform', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Fleet dashboard, manifests & QR boarding', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & App Info
            AppCard(
              child: Column(
                children: [
                  _buildNavTile(
                    Icons.language_outlined,
                    'Language (ቋንቋ)',
                    languageDisplayName,
                    onTap: () => _showLanguageDialog(context, ref),
                  ),
                  const Divider(),
                  _buildNavTile(Icons.info_outline, 'About EthioLiner', 'v1.0.0'),
                  const Divider(),
                  _buildNavTile(Icons.help_outline, 'Customer Support', '+251 911 000 000'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Select Language / ቋንቋ ይምረጡ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: const Text('English'),
                  trailing: currentLocale.languageCode == 'en'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇪🇹', style: TextStyle(fontSize: 24)),
                  title: const Text('አማርኛ (Amharic)'),
                  trailing: currentLocale.languageCode == 'am'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('am'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇪🇹', style: TextStyle(fontSize: 24)),
                  title: const Text('Afaan Oromoo'),
                  trailing: currentLocale.languageCode == 'om'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('om'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, String trailing, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.bodyMedium),
            const Spacer(),
            Text(trailing, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
            ],
          ],
        ),
      ),
    );
  }
}
