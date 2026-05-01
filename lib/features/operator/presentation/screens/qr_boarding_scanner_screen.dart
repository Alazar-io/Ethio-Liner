import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/models/operator_models.dart';
import '../providers/operator_provider.dart';

class QrBoardingScannerScreen extends ConsumerStatefulWidget {
  const QrBoardingScannerScreen({super.key});

  @override
  ConsumerState<QrBoardingScannerScreen> createState() => _QrBoardingScannerScreenState();
}

class _QrBoardingScannerScreenState extends ConsumerState<QrBoardingScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onScanSample(String sampleData) {
    ref.read(qrBoardingProvider.notifier).validateAndBoard(sampleData);
  }

  void _onManualSubmit() {
    final text = _manualInputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(qrBoardingProvider.notifier).validateAndBoard(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(qrBoardingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('QR Boarding Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isManualMode ? Icons.qr_code_scanner : Icons.keyboard),
            tooltip: _isManualMode ? 'Switch to Camera' : 'Manual Ticket Input',
            onPressed: () {
              setState(() {
                _isManualMode = !_isManualMode;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top instructions bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade900,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isManualMode
                          ? 'Enter passenger ticket reference (e.g. TCK-78421-1)'
                          : 'Align passenger QR code within the frame to verify',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Viewport / Scanner / Input Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isManualMode)
                    _buildManualEntryView(scanState)
                  else
                    _buildCameraSimView(),

                  // Scan Result Modal / Card overlay
                  if (scanState.lastResult != null)
                    _buildResultCard(scanState.lastResult!),

                  if (scanState.isProcessing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Verifying Ticket with Backend...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Demo Scenarios bar for instant testability
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF121212),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Test Simulation:',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickTestChip(
                          label: 'Valid QR (Seat 3A)',
                          color: Colors.green,
                          onTap: () => _onScanSample(
                            'ETHIOLINER:ETL-2026-78421:TCK-78421-1:1:3A:Abebe Bikila',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickTestChip(
                          label: 'Valid QR (Seat 7C)',
                          color: Colors.green,
                          onTap: () => _onScanSample(
                            'ETHIOLINER:ETL-2026-99012:TCK-99012-1:1:7C:Tirunesh Dibaba',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickTestChip(
                          label: 'Already Boarded',
                          color: Colors.amber.shade700,
                          onTap: () => _onScanSample(
                            'ETHIOLINER:ETL-2026-78421:TCK-ALREADY:1:3A:Abebe Bikila',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickTestChip(
                          label: 'Cancelled Ticket',
                          color: Colors.red,
                          onTap: () => _onScanSample('TCK-CANCELLED-999'),
                        ),
                        const SizedBox(width: 8),
                        _QuickTestChip(
                          label: 'Fake / Invalid QR',
                          color: Colors.grey,
                          onTap: () => _onScanSample('INVALID_QR_STRING_12345'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSimView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reticle box
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Reticle Corners
              _ReticleCorners(),

              // Animated Scanning Line
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Positioned(
                    top: _animController.value * 230 + 10,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.transparent, AppColors.secondary, Colors.transparent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Scanning for Passenger QR...',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildManualEntryView(QrBoardingState scanState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.confirmation_number_outlined, color: AppColors.secondary, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Manual Boarding Check-In',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If the passenger\'s camera or phone battery is depleted, enter the ticket number below.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _manualInputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade900,
                hintText: 'e.g. TCK-78421-1 or TCK-99012-1',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _onManualSubmit(),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Verify & Check In',
              icon: Icons.check,
              onPressed: _onManualSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BoardingValidationResult result) {
    Color headerColor;
    IconData headerIcon;

    switch (result.status) {
      case BoardingStatus.valid:
        headerColor = const Color(0xFF2E7D32);
        headerIcon = Icons.check_circle;
        break;
      case BoardingStatus.alreadyBoarded:
        headerColor = Colors.orange.shade800;
        headerIcon = Icons.warning_amber_rounded;
        break;
      case BoardingStatus.cancelled:
        headerColor = Colors.red.shade800;
        headerIcon = Icons.cancel;
        break;
      case BoardingStatus.expired:
        headerColor = Colors.brown.shade800;
        headerIcon = Icons.timer_off;
        break;
      case BoardingStatus.invalid:
        headerColor = Colors.red.shade900;
        headerIcon = Icons.error_outline;
        break;
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: AppCard(
        backgroundColor: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: headerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: headerColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(headerIcon, color: headerColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.status.displayName,
                          style: TextStyle(
                            color: headerColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.message,
                          style: TextStyle(
                            color: headerColor.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Passenger Info
            if (result.passengerName != null) ...[
              _InfoRow(label: 'Passenger', value: result.passengerName!),
              const Divider(height: 16),
            ],
            if (result.seatNumber != null) ...[
              _InfoRow(label: 'Assigned Seat', value: 'Seat ${result.seatNumber!}', isHighlight: true),
              const Divider(height: 16),
            ],
            if (result.route != null) ...[
              _InfoRow(label: 'Route', value: result.route!),
              const Divider(height: 16),
            ],
            if (result.ticketId != null) ...[
              _InfoRow(label: 'Ticket Ref', value: result.ticketId!),
              const Divider(height: 16),
            ],

            const SizedBox(height: 8),

            // Reset & Next Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(qrBoardingProvider.notifier).resetScanner();
                    },
                    child: const Text('Scan Next Ticket'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(qrBoardingProvider.notifier).resetScanner();
                    context.push('${RoutePaths.operatorManifest}/1');
                  },
                  child: const Text('View Manifest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: isHighlight
              ? AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _QuickTestChip extends StatelessWidget {
  const _QuickTestChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color.withValues(alpha: 0.6)),
      label: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }
}

class _ReticleCorners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const strokeWidth = 3.0;
    const cornerSize = 24.0;
    const color = AppColors.secondary;

    return Stack(
      children: [
        // Top Left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Top Right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Bottom Left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Bottom Right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
