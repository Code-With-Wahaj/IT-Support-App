import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pc_position_model.dart';
import '../../providers/lab_provider.dart';
import '../../models/lab_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'package:uuid/uuid.dart';

class AddEditLabScreen extends StatefulWidget {
  final LabModel? lab;
  const AddEditLabScreen({super.key, this.lab});

  @override
  State<AddEditLabScreen> createState() => _AddEditLabScreenState();
}

class _AddEditLabScreenState extends State<AddEditLabScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedLabName;

  int rows = 4;
  int columns = 5;
  String layoutType = 'theater';
  final Set<String> disabledPcs = {};

  /// 🔹 Allowed Lab Names
  late final List<String> labNames;

  @override
  void initState() {
    super.initState();

    labNames = [
      ...List.generate(10, (i) => 'Lab ${101 + i}'),
      ...List.generate(20, (i) => 'Lab ${201 + i}'),
      'JBR Lab',
      'IBR Lab',
    ];

    if (widget.lab != null) {
      selectedLabName = widget.lab!.name;
      rows = widget.lab!.rows;
      columns = widget.lab!.columns;
      disabledPcs.addAll(widget.lab!.disabledPcs);
      final incoming = widget.lab!.layoutType.toLowerCase().trim();
      if (incoming == 'u' || incoming == 'u shape' || incoming == 'u-shaped') {
        layoutType = 'u';
      } else if (incoming == 'custom' || incoming == 'custom theater') {
        layoutType = 'custom';
      } else {
        layoutType = 'theater';
      }
    }
  }

  /// Backbone Function for Lab Structure
  List<PcPosition> _generateGrid() {
    final List<PcPosition> grid = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        final pcId = 'PC-${r + 1}-${c + 1}';
        grid.add(
          PcPosition(
            row: r,
            column: c,
            isActive: !disabledPcs.contains(pcId),
            pcId: pcId,
          ),
        );
      }
    }
    return grid;
  }

  /// 🔹 LIVE PREVIEW WITH INTERACTIVE "NO PC" TOGGLE
  Widget _buildPreviewGrid() {
    final grid = _generateGrid();
    final activeCount = (rows * columns) - disabledPcs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Interactive Lab Preview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$activeCount Active • ${disabledPcs.length} No PC',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '💡 Tap any workstation below to toggle it as "No PC" (empty desk). It will disappear from the 3D topology.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: List.generate(rows, (r) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(columns, (c) {
                      final pc = grid.firstWhere(
                        (e) => e.row == r && e.column == c,
                      );
                      final isNoPc = disabledPcs.contains(pc.pcId);

                      return Tooltip(
                        message: isNoPc
                            ? 'Tap to restore ${pc.pcId}'
                            : 'Tap to mark ${pc.pcId} as No PC',
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isNoPc) {
                                disabledPcs.remove(pc.pcId);
                              } else {
                                disabledPcs.add(pc.pcId);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 48,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isNoPc
                                  ? Colors.grey.shade100
                                  : AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isNoPc
                                    ? Colors.red.shade300
                                    : AppTheme.accentColor,
                                width: isNoPc ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isNoPc
                                      ? Icons.close_rounded
                                      : Icons.desktop_windows_rounded,
                                  size: 16,
                                  color: isNoPc
                                      ? Colors.red.shade400
                                      : Colors.white,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isNoPc ? 'NO PC' : pc.pcId.replaceFirst('PC-', ''),
                                  style: TextStyle(
                                    color: isNoPc
                                        ? Colors.red.shade700
                                        : Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _saveLab() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LabProvider>();

    /// 🔒 Prevent duplicate lab creation
    final existingLabNames = provider.labs.map((e) => e.name).toList();

    final isDuplicate =
        widget.lab == null && existingLabNames.contains(selectedLabName);

    if (isDuplicate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This lab already exists')));
      return;
    }

    final lab = LabModel(
      id: widget.lab?.id ?? const Uuid().v4(),
      name: selectedLabName!,
      rows: rows,
      columns: columns,
      layoutType: layoutType,
      assignedTo: widget.lab?.assignedTo ?? 'Unknown',
      assignedTechnicianId: widget.lab?.assignedTechnicianId ?? '',
      disabledPcs: disabledPcs.toList(),
    );

    try {
      if (widget.lab == null) {
        await provider.addLab(lab);
      } else {
        await provider.updateLabAndSyncPcs(lab);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lab == null ? 'Add Lab' : 'Edit Lab')),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsivePadding(context),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔽 LAB NAME DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedLabName,
                  decoration: const InputDecoration(labelText: 'Lab Name'),
                  items: labNames
                      .map(
                        (lab) => DropdownMenuItem(value: lab, child: Text(lab)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedLabName = v),
                  validator: (v) => v == null ? 'Please select a lab' : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: layoutType,
                  items: const [
                    DropdownMenuItem(value: 'theater', child: Text('Theater')),
                    DropdownMenuItem(value: 'u', child: Text('U-shaped')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (v) => setState(() => layoutType = v!),
                  decoration: const InputDecoration(labelText: 'Layout Topology'),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: rows.toString(),
                        decoration: const InputDecoration(labelText: 'Rows'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          rows = int.tryParse(v) ?? rows;
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: columns.toString(),
                        decoration: const InputDecoration(labelText: 'Columns'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          columns = int.tryParse(v) ?? columns;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildPreviewGrid(),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _saveLab,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Lab'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
