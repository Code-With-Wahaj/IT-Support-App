import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/pc_tile_3d.dart';
import '../../services/export_excel_service.dart';
import '../../widgets/animations/network_background.dart';

class Lab3DViewScreen extends StatefulWidget {
  final LabModel lab;
  const Lab3DViewScreen({super.key, required this.lab});

  @override
  State<Lab3DViewScreen> createState() => _Lab3DViewScreenState();
}

class _Lab3DViewScreenState extends State<Lab3DViewScreen> {
  String _healthFilterChip = "All PCs";
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LabProvider>().ensureLabPcsInitialized(widget.lab);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Mouse wheel zoom: scroll up (negative dy) zooms in, scroll down (positive dy) zooms out
      final double zoomDelta = event.scrollDelta.dy < 0 ? 1.10 : 0.90;
      _applyZoom(zoomDelta, event.localPosition);
    }
  }

  void _applyZoom(double factor, Offset focalPoint) {
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(0.35, 3.0);
    final double actualFactor = targetScale / currentScale;

    if ((actualFactor - 1.0).abs() < 0.001) return;

    final Matrix4 translation = Matrix4.identity()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(actualFactor)
      ..translate(-focalPoint.dx, -focalPoint.dy);

    _transformationController.value = translation * currentMatrix;
  }

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
          final isInstructor = status.pcId == 'IP';
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isInstructor ? Icons.school_rounded : Icons.desktop_windows_rounded,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isInstructor ? "Instructor Node (IP)" : "Configure ${status.pcId}",
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Toggle Component Health Chips",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggleChip("CPU Working", status.cpuWorking, (v) => setDialogState(() => status.cpuWorking = v)),
                        _toggleChip("LED Monitor", status.ledOk, (v) => setDialogState(() => status.ledOk = v)),
                        _toggleChip("Keyboard", status.keyboardOk, (v) => setDialogState(() => status.keyboardOk = v)),
                        _toggleChip("Mouse", status.mouseOk, (v) => setDialogState(() => status.mouseOk = v)),
                        _toggleChip("VGA / Display Cable", status.vgaCableOk, (v) => setDialogState(() => status.vgaCableOk = v)),
                        _toggleChip("Power Cable", status.powerCableOk, (v) => setDialogState(() => status.powerCableOk = v)),
                        _toggleChip("Ethernet / LAN", status.internetCableOk, (v) => setDialogState(() => status.internetCableOk = v)),
                      ],
                    ),
                    const SizedBox(height: 16),
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
              if (!isInstructor)
                TextButton.icon(
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: const Text('Mark as No PC'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                  onPressed: () async {
                    Navigator.pop(context);
                    await provider.togglePcActiveStatus(widget.lab.id, status.pcId, true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${status.pcId} removed from topology"),
                          backgroundColor: Colors.orange.shade800,
                        ),
                      );
                    }
                  },
                ),
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
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          color: value ? Colors.white : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: value,
      selectedColor: AppTheme.successColor,
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

  String _formatTopologyTitle(String layout) {
    final lower = layout.trim().toLowerCase();
    if (lower == 'u' || lower == 'u shape' || lower == 'u-shaped') return "U-SHAPED";
    if (lower == 'custom' || lower == 'custom theater') return "CUSTOM";
    return "THEATER";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LabProvider>();
    final bool isMobile = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);

    final normalizedLayout = widget.lab.layoutType.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.lab.name),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accentGlow.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _formatTopologyTitle(widget.lab.layoutType),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGlow,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
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
            // Instant digital-twin fallback based on lab topology
            pcs['IP'] = PcStatusModel(pcId: 'IP');
            for (int r = 1; r <= widget.lab.rows; r++) {
              for (int c = 1; c <= widget.lab.columns; c++) {
                final id = 'PC-$r-$c';
                pcs[id] = PcStatusModel(pcId: id);
              }
            }
          }

          // Filter out disabled "No PC" slots from topology
          final disabledSet = widget.lab.disabledPcs.toSet();
          for (final disId in disabledSet) {
            pcs.remove(disId);
          }

          final allList = pcs.values.toList();
          final healthyCount = allList.where(_isPcHealthy).length;
          final faultyCount = allList.length - healthyCount;

          final instructorPc = pcs.remove('IP');

          final filteredStudentPcs = pcs.values.where((p) {
            if (_healthFilterChip == "Healthy") return _isPcHealthy(p);
            if (_healthFilterChip == "Faulty") return !_isPcHealthy(p);
            return true;
          }).toList();

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
                              showCheckmark: false,
                              label: Text(chip),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _healthFilterChip = key),
                            ),
                          );
                        }).toList(),
                      ),
                      const Text(
                        "Tap any workstation to inspect hardware status or remove",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Digital Twin Workstation Matrix with Animated Network Background
              Expanded(
                child: Stack(
                  children: [
                    // Upgraded Network Background
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: const AnimatedNetworkBackground(
                          color: AppTheme.primaryColor,
                          backgroundColor: Colors.transparent,
                          numberOfNodes: 22,
                          connectionDistance: 130,
                        ),
                      ),
                    ),

                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerSignal: _handlePointerSignal,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.35,
                        maxScale: 3.0,
                        boundaryMargin: const EdgeInsets.all(350),
                        panEnabled: true,
                        scaleEnabled: true,
                        trackpadScrollCausesScale: true,
                        child: SizedBox.expand(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                                child: _buildTopologyLayout(
                                  context,
                                  normalizedLayout,
                                  filteredStudentPcs,
                                  instructorPc,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Master Topology Switcher: Theater, U-shaped, Custom
  Widget _buildTopologyLayout(
    BuildContext context,
    String layout,
    List<PcStatusModel> studentPcs,
    PcStatusModel? instructorPc,
  ) {
    if (layout == 'u' || layout == 'u shape' || layout == 'u-shaped') {
      return _buildUShapedLayout(context, studentPcs, instructorPc);
    } else if (layout == 'custom') {
      return _buildCustomLayout(context, studentPcs, instructorPc);
    }
    // Default: Theater Layout (Drawing 2)
    return _buildTheaterLayout(context, studentPcs, instructorPc);
  }

  /// 📐 THEATER LAYOUT (Drawing 2): Dual-Bank Split Rows with Walkway + Instructor Alone on Bottom Right
  Widget _buildTheaterLayout(
    BuildContext context,
    List<PcStatusModel> studentPcs,
    PcStatusModel? instructorPc,
  ) {
    final int totalRows = widget.lab.rows;
    final int totalCols = widget.lab.columns;
    final int splitCol = (totalCols / 2).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stepped Rows of Dual Banks
        ...List.generate(totalRows, (row) {
          final rowPcs = studentPcs.where((p) => _rowOf(p.pcId) == row).toList()
            ..sort((a, b) => _colOf(a.pcId).compareTo(_colOf(b.pcId)));

          final leftBank = rowPcs.where((p) => _colOf(p.pcId) < splitCol).toList();
          final rightBank = rowPcs.where((p) => _colOf(p.pcId) >= splitCol).toList();

          if (leftBank.isEmpty && rightBank.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Bank Desks
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: leftBank.map((pc) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: PcTile3D(
                      pcId: pc.pcId,
                      status: pc,
                      isActive: true,
                      onTap: () => _openPcDialog(context, pc),
                    ),
                  )).toList(),
                ),

                // Center Walkway Aisle
                Container(
                  width: 56,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Container(
                      height: 24,
                      width: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGlow.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Right Bank Desks
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: rightBank.map((pc) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: PcTile3D(
                      pcId: pc.pcId,
                      status: pc,
                      isActive: true,
                      onTap: () => _openPcDialog(context, pc),
                    ),
                  )).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Front Stage: Instructor Workstation Sitting Alone on the Bottom Right
        if (instructorPc != null)
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Balanced left spacing so Instructor sits on the right bank
                const SizedBox(width: 140),
                const SizedBox(width: 56),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: PcTile3D(
                    pcId: 'Instructor (IP)',
                    status: instructorPc,
                    isActive: true,
                    onTap: () => _openPcDialog(context, instructorPc),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 📐 U-SHAPED LAYOUT (Drawing 1): Left Bank & Right Bank Facing Inwards + Instructor Center Bottom
  Widget _buildUShapedLayout(
    BuildContext context,
    List<PcStatusModel> studentPcs,
    PcStatusModel? instructorPc,
  ) {
    final int totalRows = widget.lab.rows;
    final int totalCols = widget.lab.columns;
    final int splitCol = (totalCols / 2).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Perimeter U-Columns
        ...List.generate(totalRows, (row) {
          final rowPcs = studentPcs.where((p) => _rowOf(p.pcId) == row).toList()
            ..sort((a, b) => _colOf(a.pcId).compareTo(_colOf(b.pcId)));

          final leftSide = rowPcs.where((p) => _colOf(p.pcId) < splitCol).toList();
          final rightSide = rowPcs.where((p) => _colOf(p.pcId) >= splitCol).toList();

          if (leftSide.isEmpty && rightSide.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Perimeter Desk
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: leftSide.map((pc) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: PcTile3D(
                      pcId: pc.pcId,
                      status: pc,
                      isActive: true,
                      onTap: () => _openPcDialog(context, pc),
                    ),
                  )).toList(),
                ),

                // Wide Open Center Floor
                const SizedBox(width: 160),

                // Right Perimeter Desk
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: rightSide.map((pc) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: PcTile3D(
                      pcId: pc.pcId,
                      status: pc,
                      isActive: true,
                      onTap: () => _openPcDialog(context, pc),
                    ),
                  )).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 32),

        // Front Center: Instructor Workstation Sitting Alone in the Middle
        if (instructorPc != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: PcTile3D(
                pcId: 'Instructor (IP)',
                status: instructorPc,
                isActive: true,
                onTap: () => _openPcDialog(context, instructorPc),
              ),
            ),
          ),
      ],
    );
  }

  /// 📐 CUSTOM LAYOUT: Full Flexible Continuous Matrix
  Widget _buildCustomLayout(
    BuildContext context,
    List<PcStatusModel> studentPcs,
    PcStatusModel? instructorPc,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(widget.lab.rows, (row) {
          final rowPcs = studentPcs.where((p) => _rowOf(p.pcId) == row).toList()
            ..sort((a, b) => _colOf(a.pcId).compareTo(_colOf(b.pcId)));

          if (rowPcs.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowPcs.map((pc) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: PcTile3D(
                    pcId: pc.pcId,
                    status: pc,
                    isActive: true,
                    onTap: () => _openPcDialog(context, pc),
                  ),
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 24),

        if (instructorPc != null)
          PcTile3D(
            pcId: 'Instructor (IP)',
            status: instructorPc,
            isActive: true,
            onTap: () => _openPcDialog(context, instructorPc),
          ),
      ],
    );
  }
}
