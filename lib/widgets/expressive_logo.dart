import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared lab-management identity, matching the launcher and web icons.
class ExpressiveAppLogo extends StatelessWidget {
  final double size;
  final bool showBadgeText;

  const ExpressiveAppLogo({
    super.key,
    this.size = 64,
    this.showBadgeText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.24),
          child: Image.asset(
            'assets/it_hub_logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Aptech IT Hub: computer labs and IT support',
          ),
        ),
        if (showBadgeText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "APTECH IT HUB",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "Lab Management & IT Support",
                style: TextStyle(
                  color: AppTheme.accentGlow.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
