import 'package:flutter/material.dart';

/// HeaderBackgroundPattern - Background Pattern Kurva Geometris Resmi
/// Berdasarkan Design System Board Resmi SMK Negeri 1 Bantul ("Background Pattern (Opsional)").
///
/// Menghadirkan siluet kurva lengkung lingkaran bertingkat (dual circular arcs)
/// yang halus dan elegan di belakang konten header, sehingga header tidak tampak datar / polos,
/// dengan tetap menjaga kontras keterbacaan teks (WCAG AAA).
class HeaderBackgroundPattern extends StatelessWidget {
  final Color tintColor;
  final Widget? child;

  const HeaderBackgroundPattern({
    super.key,
    this.tintColor = Colors.white,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeaderBackgroundPatternPainter(tintColor: tintColor),
      child: child,
    );
  }
}

class _HeaderBackgroundPatternPainter extends CustomPainter {
  final Color tintColor;

  const _HeaderBackgroundPatternPainter({required this.tintColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Lengkungan Kiri Bawah (Left Bottom Arc)
    final leftPaint = Paint()
      ..color = tintColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-size.width * 0.06, size.height * 0.88),
      size.height * 0.72,
      leftPaint,
    );

    // 2. Sapuan Lengkung Kanan Atas (Right Top Outer Sweep)
    final rightOuterPaint = Paint()
      ..color = tintColor.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.94, -size.height * 0.12),
      size.width * 0.52,
      rightOuterPaint,
    );

    // 3. Lengkungan Konsentris Kanan Bawah (Right Bottom Concentric Arc)
    final rightInnerPaint = Paint()
      ..color = tintColor.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.98, size.height * 0.84),
      size.width * 0.36,
      rightInnerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeaderBackgroundPatternPainter oldDelegate) {
    return oldDelegate.tintColor != tintColor;
  }
}

