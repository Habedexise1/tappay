import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class GlobeIllustration extends StatelessWidget {
  final bool animate;

  const GlobeIllustration({
    super.key,
    this.animate = true,
  });

  Widget _wrap(Widget child, {required double moveX, required double moveY, required int durationMs}) {
    if (!animate) return child;
    var a = child.animate(onPlay: (c) => c.repeat(reverse: true));
    if (moveX != 0) {
      a = a.moveX(begin: 0, end: moveX, duration: Duration(milliseconds: durationMs));
    }
    if (moveY != 0) {
      a = a.moveY(begin: 0, end: moveY, duration: Duration(milliseconds: durationMs));
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    Widget globe = Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _GlobeContinentsPainter(),
      ),
    );

    if (animate) {
      globe = globe
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 2500.ms);
    }

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Yellow Globe with custom painted continental lines
          globe,

          // 1. Top Euro (€)
          Positioned(
            top: 10,
            child: _wrap(
              const _CurrencyBadge(symbol: '€'),
              moveX: 0,
              moveY: -6,
              durationMs: 2000,
            ),
          ),

          // 2. Left Pound (£)
          Positioned(
            left: 20,
            top: 55,
            child: _wrap(
              const _CurrencyBadge(symbol: '£'),
              moveX: -5,
              moveY: 0,
              durationMs: 2400,
            ),
          ),

          // 3. Bottom-Left Naira (₦)
          Positioned(
            left: 28,
            bottom: 50,
            child: _wrap(
              const _CurrencyBadge(symbol: '₦'),
              moveX: 0,
              moveY: 5,
              durationMs: 2200,
            ),
          ),

          // 4. Right Bitcoin (₿)
          Positioned(
            right: 20,
            top: 85,
            child: _wrap(
              const _CurrencyBadge(symbol: '₿'),
              moveX: 6,
              moveY: 0,
              durationMs: 2600,
            ),
          ),

          // 5. Bottom Dollar ($)
          Positioned(
            bottom: 12,
            right: 75,
            child: _wrap(
              const _CurrencyBadge(symbol: '\$'),
              moveX: 0,
              moveY: 6,
              durationMs: 2100,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  final String symbol;

  const _CurrencyBadge({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        symbol,
        style: const TextStyle(
          fontFamily: 'Gordita',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1311),
        ),
      ),
    );
  }
}

class _GlobeContinentsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.40, size.height * 0.24, size.width * 0.35, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.55, size.width * 0.50, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.75, size.width * 0.40, size.height * 0.90);

    final path2 = Path()
      ..moveTo(size.width * 0.50, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.70, size.height * 0.22, size.width * 0.85, size.height * 0.18);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
