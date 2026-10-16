import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/pc_tile_3d.dart';
import '../../services/export_excel_service.dart';

class Lab3DViewScreen extends StatefulWidget {
  final LabModel lab;
  const Lab3DViewScreen({super.key, required this.lab});

  @override
  State<Lab3DViewScreen> createState() => _Lab3DViewScreenState();
}

class _Lab3DViewScreenState extends State<Lab3DViewScreen> {
  String _healthFilterChip = "All PCs";

  bool _isPcHealthy(PcStatusModel s) {
    return s.keyboardOk &&
        s.mouseOk &&
        s.ledOk &&
        s.cpuWorking &&
        s.vgaCableOk &&
        s.powerCableOk &&
        s.internetCableOk;
  }

  void _openPcDialog(BuildContext context, PcStatusModel original) async {
    final provider = context.read<LabProvider>();
    final status = original.copy();

    final ramC = TextEditingController(text: status.ram);
    final ssdC = TextEditingController(text: status.ssd);
    final osC = TextEditingController(text: status.os);
    final notesC = TextEditingController(text: status.notes);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.desktop_windows_rounded, color: AppTheme.accentColor),
                const SizedBox(width: 10),
                Text("Configure ${status.pcId}"),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Toggle Component Health Chips",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggleChip(
                          "CPU Working",
                          status.cpuWorking,
                          (v) => setDialogState(() => status.cpuWorking = v),
                        ),
                        _toggleChip(
                          "LED Monitor",
                          status.ledOk,
                          (v) => setDialogState(() => status.ledOk = v),
                        ),
                        _toggleChip(
                          "Keyboard",
                          status.keyboardOk,
                          (v) => setDialogState(() => status.keyboardOk = v),
                        ),
                        _toggleChip(
                          "Mouse",
                          status.mouseOk,
                          (v) => setDialogState(() => status.mouseOk = v),
                        ),
                        _toggleChip(
                          "VGA / Display Cable",
                          status.vgaCableOk,
                          (v) => setDialogState(() => status.vgaCableOk = v),
                        ),
                        _toggleChip(
                          "Power Cable",
                          status.powerCableOk,
                          (v) => setDialogState(() => status.powerCableOk = v),
                        ),
                        _toggleChip(
                          "Ethernet / LAN",
                          status.internetCableOk,
                          (v) => setDialogState(() => status.internetCableOk = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ramC,
                            decoration: const InputDecoration(labelText: 'RAM'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ssdC,
                            decoration: const InputDecoration(labelText: 'Storage'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: osC,
                      decoration: const InputDecoration(labelText: 'Operating System'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesC,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Technician Notes / Fault Details',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Telemetry'),
                onPressed: () async {
                  await provider.updatePcStatus(
                    widget.lab.id,
                    status.pcId,
                    status
                      ..ram = ramC.text
                      ..ssd = ssdC.text
                      ..os = osC.text
                      ..notes = notesC.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${status.pcId} updated'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      selectedColor: AppTheme.successColor.withOpacity(0.18),
      checkmarkColor: AppTheme.successColor,
      onSelected: onChanged,
    );
  }

  int _rowOf(String id) {
    final parts = id.split('-');
    return parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) - 1 : 0;
  }

  int _colOf(String id) {
    final parts = id.split('-');
    return parts.length > 2 ? (int.tryParse(parts[2]) ?? 1) - 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LabProvider>();
    final bool isMobile = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lab.name),
            Text(
              "Assigned Technician: ${widget.lab.assignedTo}",
              style: const TextStyle(fontSize: 11, color: AppTheme.accentGlow),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export Lab Excel Report',
              onPressed: () async {
                final pcsMap =
                    await provider.streamLabPcStatuses(widget.lab.id).first;
                await ExportExcelService.exportLabReport(
                  lab: widget.lab,
                  pcs: pcsMap.values.toList(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lab Excel report downloaded'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<Map<String, PcStatusModel>>(
        stream: provider.streamLabPcStatuses(widget.lab.id),
        builder: (context, snapshot) {
          final pcs = Map<String, PcStatusModel>.from(snapshot.data ?? {});
          if (pcs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allList = pcs.values.toList();
          final healthyCount = allList.where(_isPcHealthy).length;
          final faultyCount = allList.length - healthyCount;

          final instructorPc = pcs.remove('IP');

          return Column(
            children: [
              // Top Telemetry & Filter Chips Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: ResponsiveWrapper(
                  padding: EdgeInsets.zero,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          "All PCs (${allList.length})",
                          "Healthy ($healthyCount)",
                          "Faulty ($faultyCount)",
                        ].map((chip) {
                          final key = chip.split(' ').first;
                          final selected = _healthFilterChip.startsWith(key);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(chip),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _healthFilterChip = key),
                            ),
                          );
                        }).toList(),
                      ),
                      const Text(
                        "Tap any workstation to inspect or toggle hardware status",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Workstation Matrix
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.2,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (instructorPc != null) ...[
                            PcTile3D(
                              pcId: 'Instructor (IP)',
                              status: instructorPc,
                              isActive: true,
                              onTap: () => _openPcDialog(context, instructorPc),
                            ),
                            const SizedBox(height: 24),
                          ],
                          ...List.generate(widget.lab.rows, (row) {
                            final rowPcs = pcs.values
                                .where((p) => _rowOf(p.pcId) == row)
                                .where((p) {
                              if (_healthFilterChip == "Healthy") {
                                return _isPcHealthy(p);
                              }
                              if (_healthFilterChip == "Faulty") {
                                return !_isPcHealthy(p);
                              }
                              return true;
                            }).toList()
                              ..sort(
                                (a, b) =>
                                    _colOf(a.pcId).compareTo(_colOf(b.pcId)),
                              );

                            if (rowPcs.isEmpty) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: rowPcs.map((pc) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      child: PcTile3D(
                                        pcId: pc.pcId,
                                        status: pc,
                                        isActive: true,
                                        onTap: () => _openPcDialog(context, pc),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
