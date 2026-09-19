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
      layoutType = widget.lab!.layoutType;
    }
  }

  /// Backbone Function for Lab Structure
  List<PcPosition> _generateGrid() {
    final List<PcPosition> grid = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        grid.add(
          PcPosition(
            row: r,
            column: c,
            isActive: true,
            pcId: 'PC-${r + 1}-${c + 1}',
          ),
        );
      }
    }
    return grid;
  }

  /// 🔹 LIVE PREVIEW
  Widget _buildPreviewGrid() {
    final grid = _generateGrid();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Lab Preview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.textTertiary.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: List.generate(rows, (r) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(columns, (c) {
                    final pc = grid.firstWhere(
                      (e) => e.row == r && e.column == c,
                    );

                    return Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          pc.pcId.split('-').last,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }),
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

                DropdownButtonFormField(
                  value: layoutType,
                  items: const [
                    DropdownMenuItem(value: 'theater', child: Text('Theater')),
                    DropdownMenuItem(value: 'u', child: Text('U Shape')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (v) => setState(() => layoutType = v!),
                  decoration: const InputDecoration(labelText: 'Layout Type'),
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
