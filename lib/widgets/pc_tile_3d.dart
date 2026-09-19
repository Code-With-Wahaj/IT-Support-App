import 'package:flutter/material.dart';
import '../models/pc_status_model.dart';

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

  bool get _isHealthy {
    if (status == null) return false;

    final s = status!;
    return s.keyboardOk &&
        s.mouseOk &&
        s.ledOk &&
        s.cpuWorking &&
        s.vgaCableOk &&
        s.powerCableOk &&
        s.internetCableOk &&
        s.ram.trim().isNotEmpty &&
        s.ssd.trim().isNotEmpty &&
        s.os.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = !isActive
        ? Colors.grey.shade700
        : _isHealthy
        ? Colors.green.shade600
        : Colors.red.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateX(-0.25)
          ..rotateZ(-0.15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🖥 Monitor
            Container(
              width: 64,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: mainColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  pcId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            /// 🧠 CPU Box
            Container(
              width: 32,
              height: 10,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 6,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
