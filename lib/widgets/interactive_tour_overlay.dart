import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon = Icons.touch_app_rounded,
  });
}

/// Game-style Interactive Coach Mark Spotlight Tutorial
class InteractiveTourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;

  const InteractiveTourOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<InteractiveTourOverlay> createState() => _InteractiveTourOverlayState();
}

class _InteractiveTourOverlayState extends State<InteractiveTourOverlay> {
  int _index = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
  }

  Future<void> _locateTarget() async {
    if (!mounted || _index >= widget.steps.length) return;
    final key = widget.steps[_index].targetKey;
    final ctx = key.currentContext;

    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
      if (!mounted) return;
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _targetRect = offset & renderBox.size;
        });
        return;
      }
    }
    setState(() => _targetRect = null);
  }

  void _next() {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final screenSize = MediaQuery.of(context).size;
    final rect = _targetRect;

    // Position the tooltip card either below or above the spotlighted widget
    double cardTop = screenSize.height * 0.35;
    if (rect != null) {
      if (rect.bottom + 220 < screenSize.height) {
        cardTop = rect.bottom + 18;
      } else {
        cardTop = (rect.top - 210).clamp(24.0, screenSize.height - 240);
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dimmed background with cutout spotlight
          GestureDetector(
            onTap: _next,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(targetRect: rect),
            ),
          ),

          // Pulsing border ring around target
          if (rect != null)
            Positioned(
              left: rect.left - 6,
              top: rect.top - 6,
              width: rect.width + 12,
              height: rect.height + 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentGlow, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGlow.withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Game-style Coach Dialog Card
          Positioned(
            top: cardTop,
            left: 20,
            right: 20,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGlow, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              step.icon,
                              color: AppTheme.accentGlow,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "GUIDE • STEP ${_index + 1} OF ${widget.steps.length}",
                              style: const TextStyle(
                                color: AppTheme.accentGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onComplete,
                            child: const Text(
                              "Skip Tour",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_index > 0)
                            TextButton(
                              onPressed: () {
                                setState(() => _index--);
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _locateTarget(),
                                );
                              },
                              child: const Text(
                                "Previous",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _next,
                            icon: Icon(
                              _index == widget.steps.length - 1
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _index == widget.steps.length - 1
                                  ? "Finish Guide"
                                  : "Got It, Next",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  _SpotlightPainter({this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.76);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      final padded = targetRect!.inflate(6);
      final holePath = Path()
        ..addRRect(RRect.fromRectAndRadius(padded, const Radius.circular(14)));
      final combined = Path.combine(PathOperation.difference, fullPath, holePath);
      canvas.drawPath(combined, bgPaint);
    } else {
      canvas.drawPath(fullPath, bgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}
