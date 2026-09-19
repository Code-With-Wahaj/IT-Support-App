import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedNetworkBackground extends StatefulWidget {
  final Color color;
  final Color backgroundColor;
  final int numberOfNodes;
  final double connectionDistance;

  const AnimatedNetworkBackground({
    super.key,
    required this.color,
    required this.backgroundColor,
    this.numberOfNodes = 25,
    this.connectionDistance = 120.0,
  });

  @override
  State<AnimatedNetworkBackground> createState() =>
      _AnimatedNetworkBackgroundState();
}

class _AnimatedNetworkBackgroundState extends State<AnimatedNetworkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Node> _nodes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nodes.isEmpty) {
      final size = MediaQuery.of(context).size;
      final rnd = math.Random();
      for (int i = 0; i < widget.numberOfNodes; i++) {
        _nodes.add(
          _Node(
            x: rnd.nextDouble() * size.width,
            y: rnd.nextDouble() * size.height,
            vx: (rnd.nextDouble() - 0.5) * 0.5,
            vy: (rnd.nextDouble() - 0.5) * 0.5,
            size: rnd.nextDouble() * 4 + 2, // 🔥 bigger nodes
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _NetworkPainter(
            nodes: _nodes,
            connectionDistance: widget.connectionDistance,
            color: widget.color,
            backgroundColor: widget.backgroundColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Node {
  double x, y, vx, vy, size;

  _Node({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
  });

  void update(Size canvasSize) {
    x += vx;
    y += vy;

    if (x <= 0 || x >= canvasSize.width) vx *= -1;
    if (y <= 0 || y >= canvasSize.height) vy *= -1;
  }
}

class _NetworkPainter extends CustomPainter {
  final List<_Node> nodes;
  final double connectionDistance;
  final Color color;
  final Color backgroundColor;

  _NetworkPainter({
    required this.nodes,
    required this.connectionDistance,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// Background gradient (unchanged)
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          const Color(0xFF020617),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    /// 🔥 Brighter nodes
    final Paint nodePaint = Paint()
      ..color = color.withOpacity(0.7);

    /// 🔥 Thicker & brighter lines
    final Paint linePaint = Paint()
      ..strokeWidth = 1.2;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      node.update(size);

      canvas.drawCircle(
        Offset(node.x, node.y),
        node.size,
        nodePaint,
      );

      for (int j = i + 1; j < nodes.length; j++) {
        final other = nodes[j];
        final dx = node.x - other.x;
        final dy = node.y - other.y;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < connectionDistance) {
          final opacity =
              (1 - (distance / connectionDistance)) * 0.6; // 🔥 more visible
          linePaint.color = color.withOpacity(opacity);

          canvas.drawLine(
            Offset(node.x, node.y),
            Offset(other.x, other.y),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
