// with excel support for mobile devices

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/pc_tile_3d.dart';
import '../../services/export_excel_service.dart';

class Lab3DViewScreen extends StatelessWidget {
  final LabModel lab;
  const Lab3DViewScreen({super.key, required this.lab});

  void _openPcDialog(BuildContext context, PcStatusModel original) async {
    final provider = context.read<LabProvider>();

    // ✅ CLONE (IMPORTANT FIX)
    final status = original.copy();

    final ramC = TextEditingController(text: status.ram);
    final ssdC = TextEditingController(text: status.ssd);
    final osC = TextEditingController(text: status.os);
    final notesC = TextEditingController(text: status.notes);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.computer, color: AppTheme.accentColor),
                SizedBox(width: 2.w),
                Text(status.pcId),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hardware Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SwitchListTile(
                    title: const Text('Keyboard OK'),
                    value: status.keyboardOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.keyboardOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Mouse OK'),
                    value: status.mouseOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.mouseOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('LED OK'),
                    value: status.ledOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.ledOk = v),
                  ),
                  Divider(color: AppTheme.textTertiary.withOpacity(0.2)),
                  Text(
                    'Cables',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SwitchListTile(
                    title: const Text('VGA Cable'),
                    value: status.vgaCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.vgaCableOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Power Cable'),
                    value: status.powerCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.powerCableOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Internet Cable'),
                    value: status.internetCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) =>
                        setState(() => status.internetCableOk = v),
                  ),
                  Divider(color: AppTheme.textTertiary.withOpacity(0.2)),
                  SwitchListTile(
                    title: const Text('CPU Working'),
                    value: status.cpuWorking,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.cpuWorking = v),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: ramC,
                    decoration: InputDecoration(
                      labelText: 'RAM',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: ssdC,
                    decoration: InputDecoration(
                      labelText: 'SSD',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: osC,
                    decoration: InputDecoration(
                      labelText: 'OS',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: notesC,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await provider.updatePcStatus(
                    lab.id,
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
                        content: Text('${status.pcId} updated successfully'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  int _rowOf(String id) => int.parse(id.split('-')[1]) - 1;
  int _colOf(String id) => int.parse(id.split('-')[2]) - 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LabProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(lab.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export Lab Report',
              onPressed: () async {
                final provider = context.read<LabProvider>();

                // Get latest PC snapshot once
                final pcsMap = await provider.streamLabPcStatuses(lab.id).first;

                final pcs = pcsMap.values.toList();

                await ExportExcelService.exportLabReport(lab: lab, pcs: pcs);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Lab report exported successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
          ],
        ),

        backgroundColor: AppTheme.backgroundColor,
        body: ResponsiveWrapper(
          child: StreamBuilder<Map<String, PcStatusModel>>(
            stream: provider.streamLabPcStatuses(lab.id),
            builder: (context, snapshot) {
              final pcs = snapshot.data ?? {};

              if (pcs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.computer_outlined,
                        size: 80,
                        color: Colors.white38,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No PCs configured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final instructorPc = pcs.remove('IP');

              return SingleChildScrollView(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (instructorPc != null)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: PcTile3D(
                              pcId: 'Instructor PC',
                              status: instructorPc,
                              isActive: true,
                              onTap: () => _openPcDialog(context, instructorPc),
                            ),
                          ),
                        ...List.generate(lab.rows, (row) {
                          final rowPcs =
                              pcs.values
                                  .where((p) => _rowOf(p.pcId) == row)
                                  .toList()
                                ..sort(
                                  (a, b) =>
                                      _colOf(a.pcId).compareTo(_colOf(b.pcId)),
                                );

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: rowPcs.map((pc) {
                                return Padding(
                                  padding: const EdgeInsets.all(8),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
*/



// without excel support for mobile devices

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/pc_tile_3d.dart';
import '../../services/export_excel_service.dart';

class Lab3DViewScreen extends StatelessWidget {
  final LabModel lab;
  const Lab3DViewScreen({super.key, required this.lab});

  void _openPcDialog(BuildContext context, PcStatusModel original) async {
    final provider = context.read<LabProvider>();

    // ✅ CLONE (IMPORTANT FIX)
    final status = original.copy();

    final ramC = TextEditingController(text: status.ram);
    final ssdC = TextEditingController(text: status.ssd);
    final osC = TextEditingController(text: status.os);
    final notesC = TextEditingController(text: status.notes);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.computer, color: AppTheme.accentColor),
                SizedBox(width: 2.w),
                Text(status.pcId),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hardware Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SwitchListTile(
                    title: const Text('Keyboard OK'),
                    value: status.keyboardOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.keyboardOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Mouse OK'),
                    value: status.mouseOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.mouseOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('LED OK'),
                    value: status.ledOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.ledOk = v),
                  ),
                  Divider(color: AppTheme.textTertiary.withOpacity(0.2)),
                  Text(
                    'Cables',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SwitchListTile(
                    title: const Text('VGA Cable'),
                    value: status.vgaCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.vgaCableOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Power Cable'),
                    value: status.powerCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.powerCableOk = v),
                  ),
                  SwitchListTile(
                    title: const Text('Internet Cable'),
                    value: status.internetCableOk,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) =>
                        setState(() => status.internetCableOk = v),
                  ),
                  Divider(color: AppTheme.textTertiary.withOpacity(0.2)),
                  SwitchListTile(
                    title: const Text('CPU Working'),
                    value: status.cpuWorking,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => status.cpuWorking = v),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: ramC,
                    decoration: InputDecoration(
                      labelText: 'RAM',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: ssdC,
                    decoration: InputDecoration(
                      labelText: 'SSD',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: osC,
                    decoration: InputDecoration(
                      labelText: 'OS',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: notesC,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await provider.updatePcStatus(
                    lab.id,
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
                        content: Text('${status.pcId} updated successfully'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  int _rowOf(String id) => int.parse(id.split('-')[1]) - 1;
  int _colOf(String id) => int.parse(id.split('-')[2]) - 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LabProvider>();

    // Determine if the platform is Mobile (Android/iOS)
    final bool isMobile = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(lab.name),
          actions: [
            // Only show download button if NOT on mobile
            if (!isMobile)
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Export Lab Report',
                onPressed: () async {
                  final provider = context.read<LabProvider>();

                  // Get latest PC snapshot once
                  final pcsMap = await provider.streamLabPcStatuses(lab.id).first;

                  final pcs = pcsMap.values.toList();

                  await ExportExcelService.exportLabReport(lab: lab, pcs: pcs);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Lab report exported successfully'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
        backgroundColor: AppTheme.backgroundColor,
        body: ResponsiveWrapper(
          child: StreamBuilder<Map<String, PcStatusModel>>(
            stream: provider.streamLabPcStatuses(lab.id),
            builder: (context, snapshot) {
              final pcs = snapshot.data ?? {};

              if (pcs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.computer_outlined,
                        size: 80,
                        color: Colors.white38,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No PCs configured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final instructorPc = pcs.remove('IP');

              return SingleChildScrollView(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (instructorPc != null)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: PcTile3D(
                              pcId: 'Instructor PC',
                              status: instructorPc,
                              isActive: true,
                              onTap: () => _openPcDialog(context, instructorPc),
                            ),
                          ),
                        ...List.generate(lab.rows, (row) {
                          final rowPcs =
                          pcs.values
                              .where((p) => _rowOf(p.pcId) == row)
                              .toList()
                            ..sort(
                                  (a, b) =>
                                  _colOf(a.pcId).compareTo(_colOf(b.pcId)),
                            );

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: rowPcs.map((pc) {
                                return Padding(
                                  padding: const EdgeInsets.all(8),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}