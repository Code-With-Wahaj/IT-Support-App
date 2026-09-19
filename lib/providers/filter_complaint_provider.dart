// lib/providers/filter_complaint_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

import '../services/export_excel_service.dart';


class FilterComplaintsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Dropdown master lists
  final List<String> filterTypes = ["IT Technician", "Faculty", "Issue", "Lab"];

  final List<String> labs = [
    // Lab 101-110
    for (int i = 101; i <= 110; i++) "Lab $i",
    // Lab 201-220
    for (int i = 201; i <= 220; i++) "Lab $i",
    // Named labs
    "JBR Lab",
    "IBR Lab",
  ];

  final List<String> issues = ["Network", "Hardware", "Software", "Access", "Other"];

  /// runtime-loaded lists
  List<String> itTechnicians = [];
  List<String> faculties = [];

  /// Selections (user MUST select both before pressing Load Data)
  String? filterType;
  String? subFilter;

  /// Client-side chips
  String statusChip = "All"; // "All", "Pending", "In Progress", "Resolved"
  String? issueCategoryChip; // Network/Hardware/Software/Access/Other OR null

  /// Data buckets
  List<DocumentSnapshot> loadedComplaints = []; // result of Load Data
  List<DocumentSnapshot> displayedComplaints = []; // after applying chips

  bool loading = false;
  String? error;

  FilterComplaintsProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadUsers("IT Technician");
    await _loadUsers("Faculty");
  }

  Future<void> _loadUsers(String role) async {
    try {
      final snap = await _firestore.collection('users').where('role', isEqualTo: role).get();
      final list = snap.docs.map((d) => (d.data() as Map)['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      if (role == "IT Technician") itTechnicians = list;
      else faculties = list;
      notifyListeners();
    } catch (e) {
      // non-fatal: keep lists empty
      debugPrint("Failed to load users ($role): $e");
    }
  }

  List<String> get subFilterOptions {
    if (filterType == null) return [];
    switch (filterType) {
      case "IT Technician":
        return itTechnicians;
      case "Faculty":
        return faculties;
      case "Lab":
        return labs;
      case "Issue":
        return issues;
      default:
        return [];
    }
  }

  void setFilterType(String? type) {
    filterType = type;
    subFilter = null;
    loadedComplaints.clear();
    displayedComplaints.clear();
    statusChip = "All";
    issueCategoryChip = null;
    notifyListeners();
  }

  void setSubFilter(String? value) {
    subFilter = value;
    // do not auto fetch — user must press Load Data
    notifyListeners();
  }

  Future<void> loadData() async {
    error = null;
    if (filterType == null || subFilter == null) {
      error = "Select filter type and value first";
      notifyListeners();
      return;
    }

    loading = true;
    loadedComplaints = [];
    displayedComplaints = [];
    notifyListeners();

    try {
      if (filterType == "IT Technician") {
        // union of assignedToName OR resolvedByName
        final q1 = _firestore.collection('complaints')
            .where('assignedToName', isEqualTo: subFilter)
            .orderBy('timestamp', descending: true);

        final q2 = _firestore.collection('complaints')
            .where('resolvedByName', isEqualTo: subFilter)
            .orderBy('timestamp', descending: true);

        final snap1 = await q1.get();
        final snap2 = await q2.get();

        final Map<String, DocumentSnapshot> map = {};
        for (var d in snap1.docs) map[d.id] = d;
        for (var d in snap2.docs) map[d.id] = d;

        loadedComplaints = map.values.toList();

      } else if (filterType == "Faculty") {
        final q = _firestore.collection('complaints')
            .where('facultyName', isEqualTo: subFilter)
            .orderBy('timestamp', descending: true);
        final snap = await q.get();
        loadedComplaints = snap.docs;

      } else if (filterType == "Lab") {
        final q = _firestore.collection('complaints')
            .where('lab', isEqualTo: subFilter) // make sure dropdown matches Firestore exactly
            .orderBy('timestamp', descending: true);
        final snap = await q.get();
        loadedComplaints = snap.docs;

      } else if (filterType == "Issue") {
        final q = _firestore.collection('complaints')
            .where('issueCategory', isEqualTo: subFilter)
            .orderBy('timestamp', descending: true);
        final snap = await q.get();
        loadedComplaints = snap.docs;
      }

      // Reset chips and apply client-side filters
      statusChip = "All";
      issueCategoryChip = null;
      _applyClientFilters();

      print("Loaded complaints for $filterType/$subFilter: ${loadedComplaints.length}");

    } catch (e) {
      error = "Failed to fetch complaints: $e";
      debugPrint(error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  /// Apply client-side status + issue-category filtering to loadedComplaints
  void _applyClientFilters() {
    Iterable<DocumentSnapshot> list = loadedComplaints;

    // If an issueCategory chip is applied, filter by complaint.issueCategory
    if (issueCategoryChip != null) {
      list = list.where((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        final cat = (data['issueCategory'] ?? '').toString().trim();
        return cat.toLowerCase() == issueCategoryChip!.toLowerCase();

      });
    }

    // If status chip is not 'All', filter by status
    if (statusChip != "All") {
      list = list.where((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        final st = (data['status'] ?? '').toString();
        return st.toLowerCase() == statusChip.toLowerCase();
      });
    }

    displayedComplaints = list.toList();
    notifyListeners();
  }

  /// Public setters for chips (do not re-fetch from server — operate on loadedComplaints)
  void setStatusChip(String newStatus) {
    statusChip = newStatus;
    _applyClientFilters();
  }

  void setIssueCategoryChip(String? category) {
    issueCategoryChip = category;
    _applyClientFilters();
  }

  /// Counts computed from loadedComplaints (taking issueCategoryChip into account)
  Map<String, int> statusCounts() {
    // compute counts over loadedComplaints with current issueCategoryChip applied
    final Map<String, int> counts = {
      'All': 0,
      'Pending': 0,
      'In Progress': 0,
      'Resolved': 0,
    };

    for (var d in loadedComplaints) {
      final data = d.data() as Map<String, dynamic>? ?? {};

      // apply issueCategoryChip filter to counts if set
      if (issueCategoryChip != null) {
        final cat = (data['issueCategory'] ?? '').toString();
        if (cat.toLowerCase() != issueCategoryChip!.toLowerCase()) continue;
      }

      counts['All'] = counts['All']! + 1;
      final st = (data['status'] ?? '').toString();
      if (st.toLowerCase() == 'pending') counts['Pending'] = counts['Pending']! + 1;
      else if (st.toLowerCase() == 'in progress' || st.toLowerCase() == 'inprogress') counts['In Progress'] = counts['In Progress']! + 1;
      else if (st.toLowerCase() == 'resolved') counts['Resolved'] = counts['Resolved']! + 1;
    }

    return counts;
  }

  /// Helper: clear results
  void clearResults() {
    loadedComplaints.clear();
    displayedComplaints.clear();
    statusChip = "All";
    issueCategoryChip = null;
    notifyListeners();
  }

  Future<String?> exportToExcel() {
    return ExportExcelService.exportToExcel(loadedComplaints);
  }

}

