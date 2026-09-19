// with excel support in android


/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sizer/sizer.dart'; // Not strictly needed for this fix

import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import 'add_edit_labs_screens.dart';
import 'lab_3d_screen.dart';
import '../../services/export_excel_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class LabListScreen extends StatelessWidget {
  const LabListScreen({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};
    final associatedLabsList = data['associatedLabs'];

    List<String> labNames = [];
    if (associatedLabsList != null) {
      if (associatedLabsList is List) {
        labNames = associatedLabsList.map((e) => e.toString()).toList();
      }
    }

    return {
      'role': data['role'] ?? '',
      'name': data['name'] ?? '',
      'associatedLabs': labNames,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabProvider>();

    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!['role'] as String;
        final associatedLabs = snapshot.data!['associatedLabs'] as List<String>;
        final allLabs = provider.labs;

        final labs = role == 'Admin'
            ? allLabs
            : allLabs.where((lab) {
          final labName = lab.name.trim().toLowerCase();
          return associatedLabs
              .map((e) => e.trim().toLowerCase())
              .contains(labName);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Labs'),
            actions: [
              if (role == 'Admin')
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export All Labs',
                  onPressed: () async {
                    if (labs.isEmpty) return;
                    final Map<String, List<PcStatusModel>> labPcMap = {};

                    for (final lab in labs) {
                      final pcsMap = await provider
                          .streamLabPcStatuses(lab.id)
                          .first;
                      labPcMap[lab.id] = pcsMap.values
                          .cast<PcStatusModel>()
                          .toList();
                    }

                    await ExportExcelService.exportAllLabs(
                      labs: labs,
                      labPcMap: labPcMap,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All labs exported'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                  },
                ),
              if (role == 'Admin')
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add New Lab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditLabScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: labs.isEmpty
              ? _buildEmptyState(role)
              : SingleChildScrollView(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(context),
            ),
            // -----------------------------------------------------
            // REPLACED ResponsiveGrid WITH LayoutBuilder + Wrap
            // This allows cards to fit their content height naturally
            // -----------------------------------------------------
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine number of columns based on width
                int columns = 1;
                if (constraints.maxWidth > 600) columns = 2; // Tablet
                if (constraints.maxWidth > 1100) columns = 3; // Desktop

                // Calculate spacing
                double spacing = 15;

                // Calculate width for each item
                // (Total Width - Total Spacing) / Number of Columns
                double itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: labs.map((lab) {
                    return SizedBox(
                      width: itemWidth,
                      // The card inside will now determine its own height
                      child: _buildCompactLabCard(
                        context,
                        lab,
                        role,
                        provider,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String role) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 20),
          Text(
            'No Labs Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            role == 'Admin'
                ? 'Add your first lab using the + button'
                : 'No labs are assigned to you',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLabCard(
      BuildContext context,
      LabModel lab,
      String role,
      LabProvider provider,
      ) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias, // Ensures clean edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Lab3DViewScreen(lab: lab)),
          );
        },
        child: Container(
          // REMOVED explicit height constraints to let it hug content
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            // ✅ This tells the column to shrink to fit its children
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.computer,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded( // Changed from Flexible to Expanded for better layout
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lab.assignedTo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),

              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabInfo(Icons.grid_3x3, 'Rows', lab.rows.toString()),
                  _buildLabInfo(Icons.view_column, 'Cols', lab.columns.toString()),
                  _buildLabInfo(Icons.view_quilt, 'Layout', lab.layoutType),
                ],
              ),

              // Admin Buttons
              if (role == 'Admin') ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppTheme.accentColor),
                      constraints: const BoxConstraints(), // Removes default padding
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Edit Lab',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditLabScreen(lab: lab),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Delete Lab',
                      onPressed: () async {
                        _showDeleteDialog(context, provider, lab);
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

  // Helper for delete dialog to keep code clean
  Future<void> _showDeleteDialog(BuildContext context, LabProvider provider, LabModel lab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            const SizedBox(width: 15),
            const Text('Delete Lab'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${lab.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteLab(lab.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lab "${lab.name}" deleted'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Widget _buildLabInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13, // Slightly larger for readability
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}*/


// without excel support in mobile apps

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for platform check
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sizer/sizer.dart'; // Not strictly needed for this fix

import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import 'add_edit_labs_screens.dart';
import 'lab_3d_screen.dart';
import '../../services/export_excel_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class LabListScreen extends StatelessWidget {
  const LabListScreen({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};
    final associatedLabsList = data['associatedLabs'];

    List<String> labNames = [];
    if (associatedLabsList != null) {
      if (associatedLabsList is List) {
        labNames = associatedLabsList.map((e) => e.toString()).toList();
      }
    }

    return {
      'role': data['role'] ?? '',
      'name': data['name'] ?? '',
      'associatedLabs': labNames,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabProvider>();

    // Check if the app is running on Android or iOS (Mobile App)
    // We use !kIsWeb to ensure we are not on the web version (where download works fine on mobile browsers)
    final bool isMobileApp = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!['role'] as String;
        final associatedLabs = snapshot.data!['associatedLabs'] as List<String>;
        final allLabs = provider.labs;

        final labs = role == 'Admin'
            ? allLabs
            : allLabs.where((lab) {
          final labName = lab.name.trim().toLowerCase();
          return associatedLabs
              .map((e) => e.trim().toLowerCase())
              .contains(labName);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Labs'),
            actions: [
              // Only show Export button if Admin AND NOT on a mobile app
              if (role == 'Admin' && !isMobileApp)
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export All Labs',
                  onPressed: () async {
                    if (labs.isEmpty) return;
                    final Map<String, List<PcStatusModel>> labPcMap = {};

                    for (final lab in labs) {
                      final pcsMap = await provider
                          .streamLabPcStatuses(lab.id)
                          .first;
                      labPcMap[lab.id] = pcsMap.values
                          .cast<PcStatusModel>()
                          .toList();
                    }

                    await ExportExcelService.exportAllLabs(
                      labs: labs,
                      labPcMap: labPcMap,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All labs exported'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                  },
                ),
              if (role == 'Admin')
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add New Lab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditLabScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: labs.isEmpty
              ? _buildEmptyState(role)
              : SingleChildScrollView(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(context),
            ),
            // -----------------------------------------------------
            // REPLACED ResponsiveGrid WITH LayoutBuilder + Wrap
            // This allows cards to fit their content height naturally
            // -----------------------------------------------------
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine number of columns based on width
                int columns = 1;
                if (constraints.maxWidth > 600) columns = 2; // Tablet
                if (constraints.maxWidth > 1100) columns = 3; // Desktop

                // Calculate spacing
                double spacing = 15;

                // Calculate width for each item
                // (Total Width - Total Spacing) / Number of Columns
                double itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                        columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: labs.map((lab) {
                    return SizedBox(
                      width: itemWidth,
                      // The card inside will now determine its own height
                      child: _buildCompactLabCard(
                        context,
                        lab,
                        role,
                        provider,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String role) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 20),
          Text(
            'No Labs Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            role == 'Admin'
                ? 'Add your first lab using the + button'
                : 'No labs are assigned to you',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLabCard(
      BuildContext context,
      LabModel lab,
      String role,
      LabProvider provider,
      ) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias, // Ensures clean edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Lab3DViewScreen(lab: lab)),
          );
        },
        child: Container(
          // REMOVED explicit height constraints to let it hug content
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            // ✅ This tells the column to shrink to fit its children
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.computer,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    // Changed from Flexible to Expanded for better layout
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lab.assignedTo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),

              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabInfo(Icons.grid_3x3, 'Rows', lab.rows.toString()),
                  _buildLabInfo(
                      Icons.view_column, 'Cols', lab.columns.toString()),
                  _buildLabInfo(Icons.view_quilt, 'Layout', lab.layoutType),
                ],
              ),

              // Admin Buttons
              if (role == 'Admin') ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          size: 20, color: AppTheme.accentColor),
                      constraints:
                      const BoxConstraints(), // Removes default padding
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Edit Lab',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditLabScreen(lab: lab),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete,
                          size: 20, color: AppTheme.errorColor),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Delete Lab',
                      onPressed: () async {
                        _showDeleteDialog(context, provider, lab);
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

  // Helper for delete dialog to keep code clean
  Future<void> _showDeleteDialog(
      BuildContext context, LabProvider provider, LabModel lab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            const SizedBox(width: 15),
            const Text('Delete Lab'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${lab.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteLab(lab.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lab "${lab.name}" deleted'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Widget _buildLabInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13, // Slightly larger for readability
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}