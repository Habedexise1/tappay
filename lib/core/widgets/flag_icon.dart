import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlagIcon extends StatelessWidget {
  final String? assetPath;
  final String fallbackEmoji;
  final double width;
  final double height;
  final double borderRadius;

  const FlagIcon({
    super.key,
    this.assetPath,
    required this.fallbackEmoji,
    this.width = 24,
    this.height = 18,
    this.borderRadius = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SvgPicture.asset(
          assetPath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }
    return Text(fallbackEmoji, style: TextStyle(fontSize: height, height: 1.0));
  }
}
