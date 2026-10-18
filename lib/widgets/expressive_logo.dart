import 'package:flutter/material.dart';

/// Clean, frosted glass logo container for Aptech IT Hub.
/// Matches the glass style of the Aptech logo across splash and auth screens.
class ExpressiveAppLogo extends StatelessWidget {
  final double size;
  final double? padding;
  final double? borderRadius;

  const ExpressiveAppLogo({
    super.key,
    this.size = 64,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final p = padding ?? (size <= 40 ? 6.0 : 10.0);
    final r = borderRadius ?? (size <= 40 ? 10.0 : 16.0);

    return Container(
      padding: EdgeInsets.all(p),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r * 0.6),
        child: Image.asset(
          'assets/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Aptech IT Hub Logo',
          errorBuilder: (_, __, ___) =>
              Icon(Icons.hub_rounded, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
