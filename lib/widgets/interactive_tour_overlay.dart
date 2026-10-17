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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      final overlayCtx = context;
      if (!overlayCtx.mounted) return;

      final renderBox = ctx.findRenderObject() as RenderBox?;
      final overlayBox = overlayCtx.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && overlayBox != null && overlayBox.hasSize) {
        final localOffset = overlayBox.globalToLocal(renderBox.localToGlobal(Offset.zero));
        setState(() {
          _targetRect = localOffset & renderBox.size;
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
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final rect = _targetRect;

    final double topSafe = padding.top + 16.0;
    final double bottomSafe = screenSize.height - padding.bottom - 16.0;

    // Determine target location to anchor tooltip safely away from spotlight
    final bool targetInLowerHalf =
        rect != null && rect.center.dy > (screenSize.height * 0.48);

    // Compute safe card clamping
    double? cardTop;
    double? cardBottom;
    double maxCardHeight;

    if (rect != null) {
      if (targetInLowerHalf) {
        // Spotlight in lower half (e.g. FAB, chips): Anchor card above target
        cardBottom = (screenSize.height - rect.top + 14.0)
            .clamp(padding.bottom + 16.0, screenSize.height - topSafe - 120.0);
        maxCardHeight = (rect.top - topSafe - 20.0).clamp(160.0, 360.0);
      } else {
        // Spotlight in upper half: Anchor card below target
        cardTop = (rect.bottom + 14.0)
            .clamp(topSafe, bottomSafe - 160.0);
        maxCardHeight = (bottomSafe - rect.bottom - 20.0).clamp(160.0, 360.0);
      }
    } else {
      cardTop = (screenSize.height * 0.32).clamp(topSafe, bottomSafe - 240.0);
      maxCardHeight = 280.0;
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dimmed background with cutout spotlight
          GestureDetector(
            onTap: _next,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(targetRect: rect),
            ),
          ),

          // Pulsing border ring around target (strictly clamped to viewport)
          if (rect != null) ...[
            Builder(
              builder: (_) {
                final safeLeft = (rect.left - 6.0).clamp(8.0, screenSize.width - 24.0);
                final safeTopTarget = (rect.top - 6.0).clamp(topSafe - 8.0, bottomSafe);
                final safeWidth = (rect.width + 12.0)
                    .clamp(16.0, screenSize.width - safeLeft - 8.0);
                final safeHeight = (rect.height + 12.0)
                    .clamp(16.0, screenSize.height - safeTopTarget - 8.0);

                return Positioned(
                  left: safeLeft,
                  top: safeTopTarget,
                  width: safeWidth,
                  height: safeHeight,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentGlow, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGlow.withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Game-style Coach Dialog Card (always within SafeArea boundaries)
          Positioned(
            top: cardTop,
            bottom: cardBottom,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 460,
                    maxHeight: maxCardHeight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGlow, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  step.icon,
                                  color: AppTheme.accentGlow,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "GUIDE • STEP ${_index + 1} OF ${widget.steps.length}",
                                  style: const TextStyle(
                                    color: AppTheme.accentGlow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onComplete,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Skip Tour",
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            step.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _next,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                icon: Icon(
                                  _index == widget.steps.length - 1
                                      ? Icons.check_circle_outline
                                      : Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  _index == widget.steps.length - 1
                                      ? "Finish Guide"
                                      : "Got It, Next",
                                  style: const TextStyle(fontSize: 13),
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
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.76);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      final safeLeft = (targetRect!.left - 6.0).clamp(4.0, size.width - 16.0);
      final safeTop = (targetRect!.top - 6.0).clamp(4.0, size.height - 16.0);
      final safeRight = (targetRect!.right + 6.0).clamp(safeLeft + 12.0, size.width - 4.0);
      final safeBottom = (targetRect!.bottom + 6.0).clamp(safeTop + 12.0, size.height - 4.0);

      final padded = Rect.fromLTRB(safeLeft, safeTop, safeRight, safeBottom);
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
