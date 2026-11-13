import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class CustomCardsIllustration extends StatelessWidget {
  final bool isDark;
  final bool animate;

  const CustomCardsIllustration({
    super.key,
    required this.isDark,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget backCard = Positioned(
      left: 20,
      top: 20,
      child: Transform.rotate(
        angle: -16 * (math.pi / 180),
        child: Container(
          width: 145,
          height: 215,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(-4, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                top: 14,
                right: 14,
                child: _MastercardLogo(size: 24),
              ),
              Positioned(
                bottom: 30,
                left: 12,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: const Text(
                    'tappay.',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (animate) {
      backCard = backCard
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(
            begin: 0,
            end: -0.015,
            duration: 2600.ms,
            curve: Curves.easeInOut,
          );
    }

    Widget frontCard = Positioned(
      right: 25,
      top: 15,
      child: Transform.rotate(
        angle: 10 * (math.pi / 180),
        child: Container(
          width: 150,
          height: 220,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardWhite : AppColors.cardBlack,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(6, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                top: 14,
                right: 14,
                child: _MastercardLogo(size: 24),
              ),
              Positioned(
                top: 48,
                left: 14,
                right: 14,
                child: CustomPaint(
                  size: const Size(122, 100),
                  painter: _CardArtworkPainter(isLightArt: !isDark),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  'tappay.',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (animate) {
      frontCard = frontCard
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(
            begin: 0,
            end: 0.015,
            duration: 2400.ms,
            curve: Curves.easeInOut,
          );
    }

    return SizedBox(
      width: 320,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [backCard, frontCard],
      ),
    );
  }
}

class _MastercardLogo extends StatelessWidget {
  final double size;

  const _MastercardLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5F00).withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardArtworkPainter extends CustomPainter {
  final bool isLightArt;

  const _CardArtworkPainter({required this.isLightArt});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLightArt ? Colors.white : Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(
      Offset(size.width * 0.15, 20),
      Offset(size.width * 0.05, 12),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, 30),
      Offset(size.width * 0.08, 30),
      paint,
    );

    final hand1 = Path()
      ..moveTo(size.width * 0.25, 45)
      ..lineTo(size.width * 0.45, 30)
      ..lineTo(size.width * 0.55, 36)
      ..lineTo(size.width * 0.38, 55);

    final hand2 = Path()
      ..moveTo(size.width * 0.22, 65)
      ..lineTo(size.width * 0.48, 52)
      ..lineTo(size.width * 0.58, 60)
      ..lineTo(size.width * 0.35, 76);

    canvas.drawPath(hand1, paint);
    canvas.drawPath(hand2, paint);

    final textSpan = TextSpan(
      text: 'Agba',
      style: TextStyle(
        fontFamily: 'Gordita',
        fontStyle: FontStyle.italic,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isLightArt ? Colors.white : Colors.black,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(size.width * 0.72, 38);
    canvas.rotate(-math.pi / 2.5);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CardArtworkPainter oldDelegate) =>
      oldDelegate.isLightArt != isLightArt;
}
