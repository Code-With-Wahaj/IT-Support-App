import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../providers/app_data_provider.dart';
import 'add_edit_labs_screens.dart';
import 'lab_3d_screen.dart';
import '../../services/export_excel_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class LabListScreen extends StatefulWidget {
  const LabListScreen({super.key});

  @override
  State<LabListScreen> createState() => _LabListScreenState();
}

class _LabListScreenState extends State<LabListScreen> {
  String _selectedLayoutChip = "All Layouts";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabProvider>();
    final appData = context.watch<AppDataProvider>();
    final isAdmin = appData.isAdmin;
    final associatedLabs = appData.associatedLabs;

    final bool isMobileApp = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final roleLabs = isAdmin
        ? provider.labs
        : provider.labs.where((lab) {
            final labName = lab.name.trim().toLowerCase();
            return associatedLabs
                .map((e) => e.trim().toLowerCase())
                .contains(labName);
          }).toList();

    final filteredLabs = roleLabs.where((lab) {
      final layoutMatch = _selectedLayoutChip == "All Layouts" ||
          lab.layoutType.toLowerCase() == _selectedLayoutChip.toLowerCase();
      final searchMatch = _searchQuery.isEmpty ||
          lab.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lab.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase());
      return layoutMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Twin Labs'),
        actions: [
          if (isAdmin && !isMobileApp)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export All Labs (.xlsx)',
              onPressed: () async {
                if (roleLabs.isEmpty) return;
                final Map<String, List<PcStatusModel>> labPcMap = {};
                for (final lab in roleLabs) {
                  final pcsMap =
                      await provider.streamLabPcStatuses(lab.id).first;
                  labPcMap[lab.id] = pcsMap.values.toList();
                }
                await ExportExcelService.exportAllLabs(
                  labs: roleLabs,
                  labPcMap: labPcMap,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All labs exported to Excel'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_box_rounded),
              tooltip: 'Create New Lab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditLabScreen()),
                );
              },
            ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search & Chip Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: const InputDecoration(
                      hintText: "Search by Lab number or assigned technician...",
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All Layouts", "Theater", "U", "Custom"]
                          .map((layout) {
                        final selected = _selectedLayoutChip == layout;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              layout == "U" ? "U-Shape Layout" : layout,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppTheme.primaryColor,
                            onSelected: (_) =>
                                setState(() => _selectedLayoutChip = layout),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredLabs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.computer_outlined,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAdmin
                                ? 'No labs match your filter. Add a new lab with +'
                                : 'No labs are currently assigned to your account',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = 1;
                          if (constraints.maxWidth > 620) columns = 2;
                          if (constraints.maxWidth > 1020) columns = 3;
                          const double spacing = 16;
                          final double itemWidth =
                              (constraints.maxWidth - (spacing * (columns - 1))) /
                                  columns;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: filteredLabs.map((lab) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildModernLabCard(
                                  context,
                                  lab,
                                  isAdmin,
                                  provider,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLabCard(
    BuildContext context,
    LabModel lab,
    bool isAdmin,
    LabProvider provider,
  ) {
    final totalWorkstations = (lab.rows * lab.columns) + 1;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Lab3DViewScreen(lab: lab)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.developer_board_rounded,
                      color: AppTheme.accentGlow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.engineering_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lab.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$totalWorkstations PCs",
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _specItem(Icons.table_rows_rounded, "Rows", "${lab.rows}"),
                    _specItem(
                      Icons.view_column_rounded,
                      "Columns",
                      "${lab.columns}",
                    ),
                    _specItem(
                      Icons.dashboard_customize_rounded,
                      "Topology",
                      lab.layoutType.toUpperCase(),
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text("Configure"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditLabScreen(lab: lab),
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text("Delete"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Lab"),
                            content: Text(
                              "Delete ${lab.name} and all its workstation records?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await provider.deleteLab(lab.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _specItem(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
