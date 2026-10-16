import 'package:flutter/material.dart';
import '../models/pc_status_model.dart';
import '../theme/app_theme.dart';

/// Clean, Professional Isometric Digital-Twin Workstation Card
class PcTile3D extends StatelessWidget {
  final String pcId;
  final bool isActive;
  final PcStatusModel? status;
  final VoidCallback onTap;

  const PcTile3D({
    super.key,
    required this.pcId,
    required this.isActive,
    required this.onTap,
    this.status,
  });

  bool get isHealthy {
    if (status == null) return false;
    final s = status!;
    return s.keyboardOk &&
        s.mouseOk &&
        s.ledOk &&
        s.cpuWorking &&
        s.vgaCableOk &&
        s.powerCableOk &&
        s.internetCableOk;
  }

  @override
  Widget build(BuildContext context) {
    final s = status;
    final healthy = isHealthy;
    final accent = !isActive
        ? AppTheme.textTertiary
        : healthy
            ? AppTheme.successColor
            : AppTheme.errorColor;

    final isInstructor = pcId.toLowerCase().contains('instructor') || pcId == 'IP';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isInstructor ? 156 : 124,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withOpacity(0.65),
              width: healthy ? 1.5 : 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Status Pill & PC ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      pcId,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Isometric Monitor Graphic
              Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    isInstructor
                        ? Icons.cast_for_education_rounded
                        : healthy
                            ? Icons.desktop_windows_rounded
                            : Icons.report_problem_rounded,
                    color: healthy ? AppTheme.accentGlow : AppTheme.errorColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Peripheral Micro-LED Indicators (CPU, Display, Input, LAN)
              if (s != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _microDot(Icons.memory, s.cpuWorking),
                    _microDot(Icons.monitor, s.ledOk && s.vgaCableOk),
                    _microDot(Icons.mouse, s.keyboardOk && s.mouseOk),
                    _microDot(Icons.lan, s.internetCableOk),
                  ],
                ),
              if (s != null) ...[
                const SizedBox(height: 6),
                Text(
                  "${s.ram} • ${s.ssd}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _microDot(IconData icon, bool ok) {
    return Icon(
      icon,
      size: 13,
      color: ok ? AppTheme.successColor : AppTheme.errorColor,
    );
  }
}
