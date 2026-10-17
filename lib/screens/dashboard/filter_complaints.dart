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
            body: SafeArea(
              top: false,
              child: ResponsiveWrapper(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "2. Select ${prov.filterType}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (prov.subFilter != null)
                                TextButton.icon(
                                  onPressed: () {
                                    prov.setSubFilter(null);
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 14),
                                  label: const Text("Clear Selection", style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.errorColor,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Searchable Dropdown Field for Faculty, Lab, and Technician
                          if (prov.filterType == "Faculty" ||
                              prov.filterType == "Lab" ||
                              prov.filterType == "IT Technician") ...[
                            InkWell(
                              onTap: () => _showSearchablePicker(
                                context: context,
                                title: "Select ${prov.filterType}",
                                items: prov.subFilterOptions,
                                selectedValue: prov.subFilter,
                                onSelected: (val) {
                                  prov.setSubFilter(val);
                                  prov.loadData();
                                },
                              ),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: prov.subFilter != null
                                        ? AppTheme.primaryColor
                                        : AppTheme.borderColor,
                                    width: 1.3,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      prov.filterType == "Faculty"
                                          ? Icons.school_rounded
                                          : prov.filterType == "Lab"
                                              ? Icons.meeting_room_rounded
                                              : Icons.badge_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        prov.subFilter ??
                                            "Search & select ${prov.filterType} (Tap to browse)...",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: prov.subFilter != null
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: prov.subFilter != null
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.search_rounded, size: 14, color: AppTheme.primaryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${prov.subFilterOptions.length}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppTheme.primaryColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Issue categories chips
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
                                          color: selected ? Colors.white : AppTheme.textPrimary,
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
                                          color: color.withValues(alpha: 0.15),
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
          ),
        );
      },
    ),
  );
}

  void _showSearchablePicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = items
                .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${filtered.length}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Type to search...",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setModalState(() => query = ""),
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setModalState(() => query = val),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No matches found for '$query'",
                                    style: const TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, idx) {
                                final opt = filtered[idx];
                                final isSelected = opt == selectedValue;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.surfaceColor,
                                    child: Icon(
                                      title.contains("Faculty")
                                          ? Icons.person_rounded
                                          : Icons.meeting_room_rounded,
                                      size: 18,
                                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    opt,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    onSelected(opt);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
