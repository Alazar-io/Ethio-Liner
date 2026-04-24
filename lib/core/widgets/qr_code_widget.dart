import 'dart:convert';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Offline-capable QR Code widget for digital bus tickets.
///
/// Renders deterministic 2D QR matrix patterns including standard
/// finder patterns at top-left, top-right, and bottom-left, with timing
/// patterns and quiet zones.
class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 200.0,
    this.color = AppColors.onSurface,
    this.backgroundColor = Colors.white,
  });

  final String data;
  final double size;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrPainter(
          data: data,
          moduleColor: color,
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.data,
    required this.moduleColor,
  });

  final String data;
  final Color moduleColor;

  static const int _gridSize = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final moduleSize = size.width / _gridSize;
    final paint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.fill;

    // Generate pseudo-deterministic matrix based on string data hash
    final bytes = utf8.encode(data);
    final matrix = List.generate(_gridSize, (r) => List.generate(_gridSize, (c) => false));

    // Fill data pseudo-randomly seeded by data bytes
    int seed = 0;
    for (final b in bytes) {
      seed = (seed * 31 + b) & 0x7FFFFFFF;
    }

    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        // Skip finder pattern zones
        if ((r < 8 && c < 8) || (r < 8 && c >= _gridSize - 8) || (r >= _gridSize - 8 && c < 8)) {
          continue;
        }
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
        matrix[r][c] = (seed % 100) < 45;
      }
    }

    // Embed standard Finder Patterns at 3 corners
    _drawFinderPattern(matrix, 0, 0);
    _drawFinderPattern(matrix, 0, _gridSize - 7);
    _drawFinderPattern(matrix, _gridSize - 7, 0);

    // Timing patterns
    for (int i = 8; i < _gridSize - 8; i++) {
      matrix[6][i] = i.isEven;
      matrix[i][6] = i.isEven;
    }

    // Draw all modules
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (matrix[r][c]) {
          final rect = Rect.fromLTWH(
            c * moduleSize,
            r * moduleSize,
            moduleSize - 0.5,
            moduleSize - 0.5,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1)), paint);
        }
      }
    }
  }

  void _drawFinderPattern(List<List<bool>> matrix, int top, int left) {
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        final isBorder = (r == 0 || r == 6 || c == 0 || c == 6);
        final isCenter = (r >= 2 && r <= 4 && c >= 2 && c <= 4);
        matrix[top + r][left + c] = isBorder || isCenter;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.moduleColor != moduleColor;
}
