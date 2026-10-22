import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Drop-in upgraded Network Hub background featuring:
/// - Multi-layered ambient cyber-nebula gradients
/// - Subtle architectural blueprint grid with crosshair markers
/// - Multi-tier topology nodes (Core Server Hubs, Lab Terminals, Endpoints)
/// - Live animated data packets traveling across active network links
/// - Subtle plexus triangle meshing & diagnostic sonar ripples
/// - Non-blocking interactive pointer/touch telemetry probe
class AnimatedNetworkBackground extends StatefulWidget {
  final Color color;
  final Color backgroundColor;
  final int numberOfNodes;
  final double connectionDistance;

  /// Optional visual feature toggles (enabled by default for drop-in use)
  final bool enableTechGrid;
  final bool enableDataPackets;
  final bool enableSonarPulses;
  final bool enableInteractiveProbe;

  const AnimatedNetworkBackground({
    super.key,
    required this.color,
    required this.backgroundColor,
    this.numberOfNodes = 25,
    this.connectionDistance = 120.0,
    this.enableTechGrid = true,
    this.enableDataPackets = true,
    this.enableSonarPulses = true,
    this.enableInteractiveProbe = true,
  });

  @override
  State<AnimatedNetworkBackground> createState() =>
      _AnimatedNetworkBackgroundState();
}

enum _NodeTier {
  coreHub, // Primary server/lab hub with rotating orbital ring & radar pulse
  terminal, // Secondary lab node with outer status ring
  endpoint, // Standard glowing network node
}

class _AnimatedNetworkBackgroundState extends State<AnimatedNetworkBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Node> _nodes = [];
  Size _lastSize = Size.zero;
  Offset? _pointerPosition;
  Duration _lastElapsed = Duration.zero;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )
      ..addListener(_onTick)
      ..repeat();
  }

  void _onTick() {
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    double dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    // Guard against timer resets or frame spikes
    if (dt <= 0 || dt > 0.1) {
      dt = 1 / 60;
    }
    _time += dt;

    if (_lastSize != Size.zero) {
      for (final node in _nodes) {
        node.update(_lastSize, dt, _time, _pointerPosition);
      }
    }
  }

  void _initializeNodes(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _nodes.clear();
    final rnd = math.Random(42); // Seeded for balanced initial distribution

    // Scale node count slightly for larger screens while honoring widget.numberOfNodes
    final int targetCount = math.max(widget.numberOfNodes, 28);

    for (int i = 0; i < targetCount; i++) {
      final _NodeTier tier;
      if (i < (targetCount * 0.14).round()) {
        tier = _NodeTier.coreHub;
      } else if (i < (targetCount * 0.42).round()) {
        tier = _NodeTier.terminal;
      } else {
        tier = _NodeTier.endpoint;
      }

      final double depth = switch (tier) {
        _NodeTier.coreHub => 0.95 + rnd.nextDouble() * 0.25,
        _NodeTier.terminal => 0.65 + rnd.nextDouble() * 0.3,
        _NodeTier.endpoint => 0.35 + rnd.nextDouble() * 0.4,
      };

      final double baseRadius = switch (tier) {
        _NodeTier.coreHub => 5.2 + rnd.nextDouble() * 1.8,
        _NodeTier.terminal => 3.4 + rnd.nextDouble() * 1.4,
        _NodeTier.endpoint => 1.8 + rnd.nextDouble() * 1.5,
      };

      final double speedMultiplier = 18.0 * depth;
      final double angle = rnd.nextDouble() * math.pi * 2;

      _nodes.add(
        _Node(
          x: rnd.nextDouble() * size.width,
          y: rnd.nextDouble() * size.height,
          vx: math.cos(angle) * speedMultiplier,
          vy: math.sin(angle) * speedMultiplier,
          size: baseRadius,
          depth: depth,
          tier: tier,
          phase: rnd.nextDouble() * math.pi * 2,
          packetSpeed: 0.25 + rnd.nextDouble() * 0.55,
          packetOffset: rnd.nextDouble(),
          isSecondaryHue: i % 3 == 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height,
        );

        if (_nodes.isEmpty && size.width > 0 && size.height > 0) {
          _lastSize = size;
          _initializeNodes(size);
        } else if ((size.width - _lastSize.width).abs() > 1 ||
            (size.height - _lastSize.height).abs() > 1) {
          // Adapt existing node coordinates smoothly on window/orientation resize
          if (_lastSize.width > 0 && _lastSize.height > 0) {
            final scaleX = size.width / _lastSize.width;
            final scaleY = size.height / _lastSize.height;
            for (final node in _nodes) {
              node.x = (node.x * scaleX).clamp(0.0, size.width);
              node.y = (node.y * scaleY).clamp(0.0, size.height);
            }
          }
          _lastSize = size;
        }

        Widget canvasWidget = RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: _NetworkPainter(
                  nodes: _nodes,
                  connectionDistance: widget.connectionDistance * 1.15,
                  color: widget.color,
                  backgroundColor: widget.backgroundColor,
                  time: _time,
                  pointerPosition: _pointerPosition,
                  enableTechGrid: widget.enableTechGrid,
                  enableDataPackets: widget.enableDataPackets,
                  enableSonarPulses: widget.enableSonarPulses,
                ),
                size: Size.infinite,
              );
            },
          ),
        );

        if (!widget.enableInteractiveProbe) {
          return canvasWidget;
        }

        // Listener & MouseRegion are hit-test translucent so foreground UI works seamlessly
        return MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          onHover: (event) => _pointerPosition = event.localPosition,
          onExit: (_) => _pointerPosition = null,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _pointerPosition = event.localPosition,
            onPointerMove: (event) => _pointerPosition = event.localPosition,
            onPointerUp: (_) => _pointerPosition = null,
            onPointerCancel: (_) => _pointerPosition = null,
            child: canvasWidget,
          ),
        );
      },
    );
  }
}

class _Node {
  double x, y, vx, vy, size;
  final double depth;
  final _NodeTier tier;
  final double phase;
  final double packetSpeed;
  final double packetOffset;
  final bool isSecondaryHue;

  _Node({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.depth,
    required this.tier,
    required this.phase,
    required this.packetSpeed,
    required this.packetOffset,
    required this.isSecondaryHue,
  });

  void update(
    Size canvasSize,
    double dt,
    double time,
    Offset? pointer,
  ) {
    // Subtle organic wave drift so nodes don't feel purely linear
    final double waveX = math.sin(time * 0.7 + phase) * 3.5 * depth;
    final double waveY = math.cos(time * 0.6 + phase) * 3.5 * depth;

    x += (vx + waveX) * dt;
    y += (vy + waveY) * dt;

    // Gentle magnetic interaction with cursor / touch probe
    if (pointer != null) {
      final dx = pointer.dx - x;
      final dy = pointer.dy - y;
      final distSq = dx * dx + dy * dy;
      const probeRadius = 180.0;
      if (distSq > 400 && distSq < probeRadius * probeRadius) {
        final dist = math.sqrt(distSq);
        final pull = (1.0 - dist / probeRadius) * 22.0 * depth;
        x += (dx / dist) * pull * dt;
        y += (dy / dist) * pull * dt;
      }
    }

    // Soft boundary reflection with margin clamping
    const double margin = 16.0;
    if (x < margin) {
      x = margin;
      vx = vx.abs();
    } else if (x > canvasSize.width - margin) {
      x = canvasSize.width - margin;
      vx = -vx.abs();
    }

    if (y < margin) {
      y = margin;
      vy = vy.abs();
    } else if (y > canvasSize.height - margin) {
      y = canvasSize.height - margin;
      vy = -vy.abs();
    }
  }
}

class _NetworkPainter extends CustomPainter {
  final List<_Node> nodes;
  final double connectionDistance;
  final Color color;
  final Color backgroundColor;
  final double time;
  final Offset? pointerPosition;
  final bool enableTechGrid;
  final bool enableDataPackets;
  final bool enableSonarPulses;

  _NetworkPainter({
    required this.nodes,
    required this.connectionDistance,
    required this.color,
    required this.backgroundColor,
    required this.time,
    required this.pointerPosition,
    required this.enableTechGrid,
    required this.enableDataPackets,
    required this.enableSonarPulses,
  });

  /// Creates a harmonious secondary cyber accent (cyan/electric blue shift)
  Color _computeSecondaryAccent(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    final shiftedHue = (hsl.hue + 38.0) % 360.0;
    return hsl
        .withHue(shiftedHue)
        .withSaturation((hsl.saturation + 0.15).clamp(0.5, 1.0))
        .withLightness((hsl.lightness + 0.08).clamp(0.45, 0.78))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final Rect fullRect = Offset.zero & size;
    final Color secondaryColor = _computeSecondaryAccent(color);
    const Color deepObsidian = Color(0xFF020617);
    final Color midSlate = Color.lerp(backgroundColor, deepObsidian, 0.55)!;

    // -------------------------------------------------------------------------
    // 1. MULTI-STOP DEEP CYBER BACKGROUND & AMBIENT NEBULA AURAS
    // -------------------------------------------------------------------------
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.48, 1.0],
        colors: [
          backgroundColor,
          midSlate,
          deepObsidian,
        ],
      ).createShader(fullRect);

    canvas.drawRect(fullRect, bgPaint);

    // Slowly breathing ambient light orbs (gives glassmorphism cards rich depth)
    final Offset orb1Center = Offset(
      size.width * (0.22 + 0.08 * math.sin(time * 0.25)),
      size.height * (0.25 + 0.06 * math.cos(time * 0.20)),
    );
    final Offset orb2Center = Offset(
      size.width * (0.78 + 0.07 * math.cos(time * 0.22)),
      size.height * (0.72 + 0.08 * math.sin(time * 0.18)),
    );

    final double orbRadius = math.max(size.width, size.height) * 0.55;

    final Paint orb1Paint = Paint()
      ..shader = ui.Gradient.radial(
        orb1Center,
        orbRadius,
        [
          color.withOpacity(0.16),
          color.withOpacity(0.05),
          Colors.transparent,
        ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawCircle(orb1Center, orbRadius, orb1Paint);

    final Paint orb2Paint = Paint()
      ..shader = ui.Gradient.radial(
        orb2Center,
        orbRadius * 0.9,
        [
          secondaryColor.withOpacity(0.13),
          secondaryColor.withOpacity(0.04),
          Colors.transparent,
        ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawCircle(orb2Center, orbRadius * 0.9, orb2Paint);

    // -------------------------------------------------------------------------
    // 2. ARCHITECTURAL SERVER-FLOOR BLUEPRINT GRID & CROSSHAIRS
    // -------------------------------------------------------------------------
    if (enableTechGrid) {
      _drawTechGrid(canvas, size, color);
    }

    // -------------------------------------------------------------------------
    // 3. DIAGNOSTIC SONAR RIPPLES FROM CORE SERVER HUBS
    // -------------------------------------------------------------------------
    if (enableSonarPulses) {
      _drawSonarPulses(canvas, secondaryColor);
    }

    // -------------------------------------------------------------------------
    // 4. PLEXUS MESH TRIANGLES, NETWORK LINKS & LIVE DATA PACKETS
    // -------------------------------------------------------------------------
    _drawConnectionsAndPackets(canvas, secondaryColor);

    // -------------------------------------------------------------------------
    // 5. INTERACTIVE TELEMETRY PROBE (CURSOR / TOUCH TETHERS)
    // -------------------------------------------------------------------------
    if (pointerPosition != null) {
      _drawPointerProbe(canvas, pointerPosition!, secondaryColor);
    }

    // -------------------------------------------------------------------------
    // 6. MULTI-TIER NODES (CORE HUBS, LAB TERMINALS & ENDPOINTS)
    // -------------------------------------------------------------------------
    _drawNodes(canvas, secondaryColor);
  }

  void _drawTechGrid(Canvas canvas, Size size, Color primary) {
    const double gridSpacing = 64.0;
    final Paint gridPaint = Paint()
      ..color = primary.withOpacity(0.045)
      ..strokeWidth = 0.8;

    final Paint crosshairPaint = Paint()
      ..color = primary.withOpacity(0.12)
      ..strokeWidth = 1.0;

    // Subtle parallax scroll on the blueprint grid
    final double offsetX = (time * 4.0) % gridSpacing;
    final double offsetY = (time * 4.0) % gridSpacing;

    for (double x = offsetX; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = offsetY; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw precision "+" markers on every second grid intersection
    int colIndex = 0;
    for (double x = offsetX; x < size.width; x += gridSpacing) {
      colIndex++;
      if (colIndex.isOdd) continue;
      int rowIndex = 0;
      for (double y = offsetY; y < size.height; y += gridSpacing) {
        rowIndex++;
        if (rowIndex.isOdd) continue;
        canvas.drawLine(
          Offset(x - 3.5, y),
          Offset(x + 3.5, y),
          crosshairPaint,
        );
        canvas.drawLine(
          Offset(x, y - 3.5),
          Offset(x, y + 3.5),
          crosshairPaint,
        );
      }
    }
  }

  void _drawSonarPulses(Canvas canvas, Color secondaryColor) {
    final Paint sonarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (final node in nodes) {
      if (node.tier != _NodeTier.coreHub) continue;

      // Cycle a radar wave every 4.5 seconds per core hub
      final double progress = ((time * 0.22) + node.packetOffset) % 1.0;
      final double maxRadius = connectionDistance * 0.85;
      final double currentRadius = node.size + progress * maxRadius;
      final double alpha = (1.0 - progress) * (1.0 - progress) * 0.28;

      final Color waveColor = node.isSecondaryHue ? secondaryColor : color;
      sonarPaint.color = waveColor.withOpacity(alpha);

      canvas.drawCircle(Offset(node.x, node.y), currentRadius, sonarPaint);
    }
  }

  void _drawConnectionsAndPackets(Canvas canvas, Color secondaryColor) {
    final Paint linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint meshFillPaint = Paint()..style = PaintingStyle.fill;
    final Paint packetGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    final Paint packetCorePaint = Paint()..style = PaintingStyle.fill;

    final double maxDistSq = connectionDistance * connectionDistance;

    for (int i = 0; i < nodes.length; i++) {
      final nodeA = nodes[i];
      final Offset posA = Offset(nodeA.x, nodeA.y);

      for (int j = i + 1; j < nodes.length; j++) {
        final nodeB = nodes[j];
        final dx = nodeA.x - nodeB.x;
        final dy = nodeA.y - nodeB.y;
        final distSq = dx * dx + dy * dy;

        if (distSq >= maxDistSq) continue;

        final double distance = math.sqrt(distSq);
        final double proximity = 1.0 - (distance / connectionDistance);
        final Offset posB = Offset(nodeB.x, nodeB.y);

        // Boost visibility for links connected to Core Hubs
        final bool involvesHub =
            nodeA.tier == _NodeTier.coreHub || nodeB.tier == _NodeTier.coreHub;
        final double baseOpacity =
            proximity * (involvesHub ? 0.58 : 0.38) * ((nodeA.depth + nodeB.depth) * 0.5);

        final Color linkColor = (nodeA.isSecondaryHue != nodeB.isSecondaryHue)
            ? Color.lerp(color, secondaryColor, 0.5)!
            : (nodeA.isSecondaryHue ? secondaryColor : color);

        linePaint
          ..strokeWidth = involvesHub ? 1.45 : 1.0
          ..color = linkColor.withOpacity(baseOpacity.clamp(0.0, 0.85));

        canvas.drawLine(posA, posB, linePaint);

        // Subtle plexus triangle shading when 3 nearby nodes form a tight cluster
        if (proximity > 0.38) {
          for (int k = j + 1; k < nodes.length; k++) {
            final nodeC = nodes[k];
            final dxBC = nodeB.x - nodeC.x;
            final dyBC = nodeB.y - nodeC.y;
            final distSqBC = dxBC * dxBC + dyBC * dyBC;
            if (distSqBC >= maxDistSq * 0.75) continue;

            final dxAC = nodeA.x - nodeC.x;
            final dyAC = nodeA.y - nodeC.y;
            final distSqAC = dxAC * dxAC + dyAC * dyAC;
            if (distSqAC >= maxDistSq * 0.75) continue;

            final double triFactor = proximity *
                (1.0 - math.sqrt(distSqBC) / connectionDistance) *
                (1.0 - math.sqrt(distSqAC) / connectionDistance);

            meshFillPaint.color =
                linkColor.withOpacity((triFactor * 0.09).clamp(0.0, 0.06));

            final Path triangle = Path()
              ..moveTo(nodeA.x, nodeA.y)
              ..lineTo(nodeB.x, nodeB.y)
              ..lineTo(nodeC.x, nodeC.y)
              ..close();
            canvas.drawPath(triangle, meshFillPaint);
          }
        }

        // Animated telemetry data packets flowing along active links
        if (enableDataPackets &&
            (involvesHub || (i + j) % 3 == 0) &&
            proximity > 0.25) {
          final double t =
              ((time * nodeA.packetSpeed) + nodeA.packetOffset + (j * 0.17)) %
                  1.0;
          final Offset packetPos = Offset.lerp(posA, posB, t)!;
          final double packetAlpha =
              (math.sin(t * math.pi) * proximity * 0.95).clamp(0.0, 1.0);

          packetGlowPaint.color = secondaryColor.withOpacity(packetAlpha * 0.75);
          canvas.drawCircle(packetPos, 3.2, packetGlowPaint);

          packetCorePaint.color = Colors.white.withOpacity(packetAlpha * 0.9);
          canvas.drawCircle(packetPos, 1.4, packetCorePaint);
        }
      }
    }
  }

  void _drawPointerProbe(Canvas canvas, Offset pointer, Color secondaryColor) {
    const double probeRange = 160.0;
    final Paint tetherPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      final dx = pointer.dx - node.x;
      final dy = pointer.dy - node.y;
      final distSq = dx * dx + dy * dy;
      if (distSq < probeRange * probeRange) {
        final dist = math.sqrt(distSq);
        final alpha = (1.0 - dist / probeRange) * 0.45;
        tetherPaint.color = secondaryColor.withOpacity(alpha);
        canvas.drawLine(pointer, Offset(node.x, node.y), tetherPaint);
      }
    }

    // Subtle diagnostic reticle at pointer
    final Paint probeRingPaint = Paint()
      ..color = secondaryColor.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(pointer, 14.0 + 2.0 * math.sin(time * 4.0), probeRingPaint);
  }

  void _drawNodes(Canvas canvas, Color secondaryColor) {
    final Paint glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);
    final Paint corePaint = Paint()..style = PaintingStyle.fill;
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    for (final node in nodes) {
      final Offset center = Offset(node.x, node.y);
      final Color nodeColor = node.isSecondaryHue ? secondaryColor : color;
      final double pulse = 0.85 + 0.15 * math.sin(time * 2.2 + node.phase);

      switch (node.tier) {
        case _NodeTier.coreHub:
          // Outer soft bloom
          glowPaint.color = nodeColor.withOpacity(0.45 * pulse);
          canvas.drawCircle(center, node.size * 2.4, glowPaint);

          // Rotating segmented tech ring around Core Server Hubs
          ringPaint.color = nodeColor.withOpacity(0.55);
          final double ringRadius = node.size * 1.95;
          final double baseAngle = time * 0.8 + node.phase;
          final Rect arcRect = Rect.fromCircle(center: center, radius: ringRadius);
          for (int s = 0; s < 3; s++) {
            canvas.drawArc(
              arcRect,
              baseAngle + (s * 2 * math.pi / 3),
              math.pi / 2.4,
              false,
              ringPaint,
            );
          }

          // Hexagonal server core
          final Path hexPath = _createPolygonPath(center, node.size * 1.15, 6, -baseAngle * 0.5);
          corePaint.color = nodeColor.withOpacity(0.92);
          canvas.drawPath(hexPath, corePaint);

          // Bright white-hot center point
          corePaint.color = Colors.white.withOpacity(0.95);
          canvas.drawCircle(center, node.size * 0.42, corePaint);

        case _NodeTier.terminal:
          // Medium lab terminal glow
          glowPaint.color = nodeColor.withOpacity(0.32 * pulse);
          canvas.drawCircle(center, node.size * 1.9, glowPaint);

          // Subtle status ring
          ringPaint.color = nodeColor.withOpacity(0.38 * pulse);
          canvas.drawCircle(center, node.size * 1.45, ringPaint);

          // Solid node body
          corePaint.color = nodeColor.withOpacity(0.85);
          canvas.drawCircle(center, node.size * 0.85, corePaint);

          // Crisp highlight
          corePaint.color = Colors.white.withOpacity(0.75);
          canvas.drawCircle(center, node.size * 0.35, corePaint);

        case _NodeTier.endpoint:
          // Ambient endpoint particle
          glowPaint.color = nodeColor.withOpacity(0.22 * node.depth);
          canvas.drawCircle(center, node.size * 1.6, glowPaint);

          corePaint.color = nodeColor.withOpacity((0.55 + 0.3 * node.depth) * pulse);
          canvas.drawCircle(center, node.size, corePaint);
      }
    }
  }

  Path _createPolygonPath(
    Offset center,
    double radius,
    int sides,
    double rotation,
  ) {
    final Path path = Path();
    for (int i = 0; i < sides; i++) {
      final double angle = rotation + (i * 2 * math.pi / sides);
      final double px = center.dx + radius * math.cos(angle);
      final double py = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => true;
}