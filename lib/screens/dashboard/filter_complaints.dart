import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_complaint_provider.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'complaint_detail_screen.dart';

/// Upgraded Chip-First Complaint Analytics & Export Screen
class FilterComplaintsScreen extends StatelessWidget {
  const FilterComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();

    return ChangeNotifierProvider(
      create: (_) => FilterComplaintsProvider(),
      child: Consumer<FilterComplaintsProvider>(
        builder: (context, prov, _) {
          final statusCounts = prov.statusCounts();
          return Scaffold(
            appBar: AppBar(
              title: const Text("Smart Chip Filter & Export"),
              actions: [
                if (appData.isAdmin && prov.loadedComplaints.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download_rounded),
                    tooltip: "Export Excel (.xlsx)",
                    onPressed: () async {
                      await prov.exportToExcel();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Excel report downloaded"),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            body: ResponsiveWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Chip-Based Dimension Selector Card
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
                        const Text(
                          "1. Choose Filter Dimension",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: prov.filterTypes.map((type) {
                              final selected = prov.filterType == type;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    type,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: AppTheme.primaryColor,
                                  onSelected: (_) => prov.setFilterType(type),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (prov.filterType != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            "2. Select ${prov.filterType}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 42,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: prov.subFilterOptions.map((val) {
                                final selected = prov.subFilter == val;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      val,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    selected: selected,
                                    selectedColor: AppTheme.primaryColor,
                                    onSelected: (_) {
                                      prov.setSubFilter(val);
                                      prov.loadData();
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ["All", "Pending", "In Progress", "Resolved"]
                              .map((st) {
                            final count = statusCounts[st] ?? 0;
                            final selected = prov.statusChip == st;
                            return FilterChip(
                              label: Text(
                                "$st ($count)",
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: selected,
                              selectedColor: AppTheme.primaryColor,
                              checkmarkColor: Colors.white,
                              onSelected: (_) => prov.setStatusChip(st),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: prov.loading
                        ? const Center(child: CircularProgressIndicator())
                        : prov.displayedComplaints.isEmpty
                            ? const Center(
                                child: Text(
                                  "Select a filter chip above to inspect tickets",
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: prov.displayedComplaints.length,
                                itemBuilder: (context, index) {
                                  final d = prov.displayedComplaints[index];
                                  final data =
                                      (d.data() as Map<String, dynamic>?) ?? {};
                                  final status =
                                      (data['status'] ?? 'Pending').toString();
                                  final color = AppTheme.getStatusColor(status);

                                  return Card(
                                    child: ListTile(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ComplaintDetailScreen(
                                            complaintId: d.id,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        (data['message'] ?? 'No message')
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          "${data['lab'] ?? ''} • ${data['issueCategory'] ?? ''} • Assigned: ${data['assignedToName'] ?? 'N/A'}",
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(color: color),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
