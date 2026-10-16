import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Expressive animated vector logo for Aptech IT Hub
class ExpressiveAppLogo extends StatefulWidget {
  final double size;
  final bool showBadgeText;

  const ExpressiveAppLogo({
    super.key,
    this.size = 64,
    this.showBadgeText = false,
  });

  @override
  State<ExpressiveAppLogo> createState() => _ExpressiveAppLogoState();
}

class _ExpressiveAppLogoState extends State<ExpressiveAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.35),
                    blurRadius: widget.size * 0.35,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _ctrl.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size * 0.78, widget.size * 0.78),
                      painter: _HexNodePainter(),
                    ),
                  ),
                  Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: widget.size * 0.46,
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.showBadgeText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "APTECH NEXUS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "IT Support & Lab Twin",
                style: TextStyle(
                  color: AppTheme.accentGlow.withOpacity(0.9),
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

class _HexNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
