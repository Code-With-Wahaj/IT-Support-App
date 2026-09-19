// with mobile excel support

/*
// lib/screens/dashboard/filter_complaints.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/filter_complaint_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'complaint_detail_screen.dart';

class FilterComplaintsScreen extends StatelessWidget {
  const FilterComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilterComplaintsProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Filter & Export Complaints")),
        body: ResponsiveWrapper(
          child: Consumer<FilterComplaintsProvider>(
            builder: (context, prov, _) {
              final statusCounts = prov.statusCounts();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters section (scrollable with max height)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: ResponsiveUtils.isMobile(context)
                          ? 40.h
                          : 50.h,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsivePadding(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- First dropdown (Filter type) ---
                          Text(
                            "Filter by",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: prov.filterType,
                            hint: const Text("Select filter type"),
                            items: prov.filterTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => prov.setFilterType(v),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.6.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // --- Second dropdown (Sub filter) ---
                          Text(
                            "Select value",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: prov.subFilter,
                            hint: const Text("Select a value"),
                            items: prov.subFilterOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => prov.setSubFilter(v),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.6.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // --- Load Data button ---
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_download),
                                  label: Text(
                                    "Load Data",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  onPressed:
                                      (prov.filterType != null &&
                                          prov.subFilter != null &&
                                          !prov.loading)
                                      ? () => prov.loadData()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.6.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              // Clear button
                              IconButton(
                                onPressed: () => prov.clearResults(),
                                icon: Icon(Icons.clear, size: 20.sp),
                                tooltip: "Clear results",
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            height:
                                6.h, // ✅ fixed height so content always fits
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download),
                              label: Text(
                                "Export to Excel",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              onPressed: prov.loadedComplaints.isEmpty
                                  ? null
                                  : () async {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      messenger.clearSnackBars();

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Downloading file...",
                                          ),
                                          backgroundColor: AppTheme.infoColor,
                                        ),
                                      );

                                      try {
                                        final path = await prov.exportToExcel();

                                        messenger.clearSnackBars();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Download completed",
                                            ),
                                            backgroundColor:
                                                AppTheme.successColor,
                                            duration: const Duration(
                                              seconds: 4,
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        messenger.clearSnackBars();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text("Export failed: $e"),
                                            backgroundColor:
                                                AppTheme.errorColor,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.6.h,
                                  horizontal: 4.w,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // --- Status chips + Total count on right ---
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 2.w,
                                  runSpacing: 1.h,
                                  children: [
                                    _statusChip(
                                      context,
                                      prov,
                                      "All",
                                      statusCounts['All'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "Pending",
                                      statusCounts['Pending'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "In Progress",
                                      statusCounts['In Progress'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "Resolved",
                                      statusCounts['Resolved'] ?? 0,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Total: ${statusCounts['All'] ?? 0}",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),

                          // --- If Faculty or IT Technician: show issue-category chips (filter client-side) ---
                          if (prov.filterType == "IT Technician" ||
                              prov.filterType == "Faculty") ...[
                            Text(
                              "Filter by issue category",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: prov.issues.map((cat) {
                                  final selected =
                                      prov.issueCategoryChip == cat;
                                  // compute count for this category (from loadedComplaints)
                                  final count = prov.loadedComplaints.where((
                                    d,
                                  ) {
                                    final data =
                                        d.data() as Map<String, dynamic>? ?? {};
                                    final c = (data['issueCategory'] ?? '')
                                        .toString();
                                    return c.toLowerCase() == cat.toLowerCase();
                                  }).length;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 3.w),
                                    child: ChoiceChip(
                                      label: Text("$cat ($count)"),
                                      selected: selected,
                                      onSelected: (_) =>
                                          prov.setIssueCategoryChip(
                                            selected ? null : cat,
                                          ),
                                      selectedColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Results section (scrollable)
                  Expanded(
                    child: prov.loading
                        ? const Center(child: CircularProgressIndicator())
                        : prov.loadedComplaints.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: AppTheme.textSecondary,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "No data loaded",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    "Use the filters above and tap Load Data",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.getResponsivePadding(
                                context,
                              ),
                              vertical: 1.h,
                            ),
                            itemCount: prov.displayedComplaints.length,
                            itemBuilder: (context, index) {
                              final d = prov.displayedComplaints[index];
                              final data =
                                  (d.data() as Map<String, dynamic>?) ?? {};
                              final title =
                                  data['message'] ??
                                  data['title'] ??
                                  'No title';
                              final status = data['status'] ?? 'Unknown';
                              final lab = data['lab'] ?? '';
                              final issueCat = data['issueCategory'] ?? '';
                              final assigned = data['assignedToName'] ?? '';
                              final resolver = data['resolvedByName'] ?? '';

                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 0.8.h),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ComplaintDetailScreen(
                                              complaintId: d.id,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(2.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Status Row
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 16
                                                      .sp, // Increased from 14.sp
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 1.5.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 1.5.w,
                                                vertical: 0.4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(status),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 14
                                                      .sp, // Increased from 10.sp
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 0.8.h),
                                        // Lab and Issue
                                        Wrap(
                                          spacing: 1.5.w,
                                          runSpacing: 0.4.h,
                                          children: [
                                            _buildInfoChip(
                                              Icons.computer,
                                              "Lab",
                                              lab,
                                            ),
                                            _buildInfoChip(
                                              Icons.category,
                                              "Issue",
                                              issueCat,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 0.6.h),
                                        // Assigned and Resolver
                                        Wrap(
                                          spacing: 1.5.w,
                                          runSpacing: 0.4.h,
                                          children: [
                                            if (assigned.isNotEmpty)
                                              _buildInfoChip(
                                                Icons.person,
                                                "Assigned",
                                                assigned,
                                              ),
                                            if (resolver.isNotEmpty)
                                              _buildInfoChip(
                                                Icons.check_circle,
                                                "Resolved",
                                                resolver,
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 0.6.h),
                                        // Timestamp
                                        if (_formatTimestamp(
                                          data['createdAt'],
                                        ).isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 13,
                                                color: AppTheme.textTertiary,
                                              ),
                                              SizedBox(width: 1.w),
                                              Text(
                                                _formatTimestamp(
                                                  data['createdAt'],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: AppTheme.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statusChip(
    BuildContext context,
    FilterComplaintsProvider prov,
    String label,
    int count,
  ) {
    final selected = prov.statusChip == label;
    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: selected,
      onSelected: (_) => prov.setStatusChip(label),
      selectedColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textTertiary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentColor),
          SizedBox(width: 1.w),
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toString().toLowerCase();
    if (s == 'pending') return Colors.red;
    if (s == 'in progress' || s == 'inprogress') return Colors.orange;
    if (s == 'resolved') return Colors.green;
    return Colors.grey;
  }

  String _formatTimestamp(dynamic ts) {
    try {
      if (ts == null) return '';
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      return ts.toString();
    } catch (_) {
      return '';
    }
  }
}
*/


// without mobile excel support

// lib/screens/dashboard/filter_complaints.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/filter_complaint_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'complaint_detail_screen.dart';

class FilterComplaintsScreen extends StatelessWidget {
  const FilterComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if the platform is Mobile (Android/iOS)
    final bool isMobile = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);

    return ChangeNotifierProvider(
      create: (_) => FilterComplaintsProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Filter & Export Complaints")),
        body: ResponsiveWrapper(
          child: Consumer<FilterComplaintsProvider>(
            builder: (context, prov, _) {
              final statusCounts = prov.statusCounts();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters section (scrollable with max height)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: ResponsiveUtils.isMobile(context)
                          ? 40.h
                          : 50.h,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsivePadding(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- First dropdown (Filter type) ---
                          Text(
                            "Filter by",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: prov.filterType,
                            hint: const Text("Select filter type"),
                            items: prov.filterTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => prov.setFilterType(v),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.6.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // --- Second dropdown (Sub filter) ---
                          Text(
                            "Select value",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: prov.subFilter,
                            hint: const Text("Select a value"),
                            items: prov.subFilterOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => prov.setSubFilter(v),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.6.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // --- Load Data button ---
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_download),
                                  label: Text(
                                    "Load Data",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  onPressed:
                                  (prov.filterType != null &&
                                      prov.subFilter != null &&
                                      !prov.loading)
                                      ? () => prov.loadData()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.6.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              // Clear button
                              IconButton(
                                onPressed: () => prov.clearResults(),
                                icon: Icon(Icons.clear, size: 20.sp),
                                tooltip: "Clear results",
                              ),
                            ],
                          ),

                          // --- Export Button Logic (ONLY SHOW IF NOT MOBILE) ---
                          if (!isMobile) ...[
                            SizedBox(height: 2.h),
                            SizedBox(
                              height: 6.h,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: Text(
                                  "Export to Excel",
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                onPressed: prov.loadedComplaints.isEmpty
                                    ? null
                                    : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger.clearSnackBars();

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Downloading file...",
                                      ),
                                      backgroundColor: AppTheme.infoColor,
                                    ),
                                  );

                                  try {
                                    await prov.exportToExcel();

                                    messenger.clearSnackBars();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Download completed",
                                        ),
                                        backgroundColor:
                                        AppTheme.successColor,
                                        duration: const Duration(
                                          seconds: 4,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.clearSnackBars();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text("Export failed: $e"),
                                        backgroundColor:
                                        AppTheme.errorColor,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.6.h,
                                    horizontal: 4.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 2.h),

                          // --- Status chips + Total count on right ---
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 2.w,
                                  runSpacing: 1.h,
                                  children: [
                                    _statusChip(
                                      context,
                                      prov,
                                      "All",
                                      statusCounts['All'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "Pending",
                                      statusCounts['Pending'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "In Progress",
                                      statusCounts['In Progress'] ?? 0,
                                    ),
                                    _statusChip(
                                      context,
                                      prov,
                                      "Resolved",
                                      statusCounts['Resolved'] ?? 0,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Total: ${statusCounts['All'] ?? 0}",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),

                          // --- If Faculty or IT Technician: show issue-category chips ---
                          if (prov.filterType == "IT Technician" ||
                              prov.filterType == "Faculty") ...[
                            Text(
                              "Filter by issue category",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: prov.issues.map((cat) {
                                  final selected =
                                      prov.issueCategoryChip == cat;
                                  final count = prov.loadedComplaints.where((
                                      d,
                                      ) {
                                    final data =
                                        d.data() as Map<String, dynamic>? ?? {};
                                    final c = (data['issueCategory'] ?? '')
                                        .toString();
                                    return c.toLowerCase() == cat.toLowerCase();
                                  }).length;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 3.w),
                                    child: ChoiceChip(
                                      label: Text("$cat ($count)"),
                                      selected: selected,
                                      onSelected: (_) =>
                                          prov.setIssueCategoryChip(
                                            selected ? null : cat,
                                          ),
                                      selectedColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Results section (scrollable)
                  Expanded(
                    child: prov.loading
                        ? const Center(child: CircularProgressIndicator())
                        : prov.loadedComplaints.isEmpty
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "No data loaded",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Use the filters above and tap Load Data",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsivePadding(
                          context,
                        ),
                        vertical: 1.h,
                      ),
                      itemCount: prov.displayedComplaints.length,
                      itemBuilder: (context, index) {
                        final d = prov.displayedComplaints[index];
                        final data =
                            (d.data() as Map<String, dynamic>?) ?? {};
                        final title =
                            data['message'] ??
                                data['title'] ??
                                'No title';
                        final status = data['status'] ?? 'Unknown';
                        final lab = data['lab'] ?? '';
                        final issueCat = data['issueCategory'] ?? '';
                        final assigned = data['assignedToName'] ?? '';
                        final resolver = data['resolvedByName'] ?? '';

                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 0.8.h),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ComplaintDetailScreen(
                                        complaintId: d.id,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(2.w),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Title and Status Row
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 1.5.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 1.5.w,
                                          vertical: 0.4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.8.h),
                                  // Lab and Issue
                                  Wrap(
                                    spacing: 1.5.w,
                                    runSpacing: 0.4.h,
                                    children: [
                                      _buildInfoChip(
                                        Icons.computer,
                                        "Lab",
                                        lab,
                                      ),
                                      _buildInfoChip(
                                        Icons.category,
                                        "Issue",
                                        issueCat,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.6.h),
                                  // Assigned and Resolver
                                  Wrap(
                                    spacing: 1.5.w,
                                    runSpacing: 0.4.h,
                                    children: [
                                      if (assigned.isNotEmpty)
                                        _buildInfoChip(
                                          Icons.person,
                                          "Assigned",
                                          assigned,
                                        ),
                                      if (resolver.isNotEmpty)
                                        _buildInfoChip(
                                          Icons.check_circle,
                                          "Resolved",
                                          resolver,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 0.6.h),
                                  // Timestamp
                                  if (_formatTimestamp(
                                    data['createdAt'],
                                  ).isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 13,
                                          color: AppTheme.textTertiary,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          _formatTimestamp(
                                            data['createdAt'],
                                          ),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: AppTheme.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statusChip(
      BuildContext context,
      FilterComplaintsProvider prov,
      String label,
      int count,
      ) {
    final selected = prov.statusChip == label;
    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: selected,
      onSelected: (_) => prov.setStatusChip(label),
      selectedColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textTertiary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentColor),
          SizedBox(width: 1.w),
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toString().toLowerCase();
    if (s == 'pending') return Colors.red;
    if (s == 'in progress' || s == 'inprogress') return Colors.orange;
    if (s == 'resolved') return Colors.green;
    return Colors.grey;
  }

  String _formatTimestamp(dynamic ts) {
    try {
      if (ts == null) return '';
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      return ts.toString();
    } catch (_) {
      return '';
    }
  }
}