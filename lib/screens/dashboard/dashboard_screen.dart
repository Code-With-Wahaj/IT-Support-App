import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aptech_it_support/routes/app_routes.dart';
import 'package:aptech_it_support/theme/app_theme.dart';
import 'package:aptech_it_support/utils/responsive_utils.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      userName = doc.data()?['name'] ?? '';
      role = doc.data()?['role'] ?? '';
    });
  }

  // ---------------- LOGOUT ----------------

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Do you really want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  // ---------------- UI HELPERS ----------------

  Widget _welcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.85),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          vertical: ResponsiveUtils.getResponsivePadding(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back",
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 0.5.h),
            Text(
              userName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, int count, Color color, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = ResponsiveUtils.isMobile(context)
        ? (screenWidth - 48) / 3 - 8
        : ResponsiveUtils.isTablet(context)
        ? (screenWidth - 64) / 3 - 12
        : 180.0;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.isMobile(context) ? 12 : 16,
        horizontal: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.isMobile(context) ? 20 : 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: ResponsiveUtils.isMobile(context) ? 20.sp : 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtils.isMobile(context) ? 14.sp : 12.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsivePadding(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ROLE DASHBOARDS ----------------

  Widget _facultyDashboard() {
    String selectedStatus = "all";

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),
              SizedBox(height: 3.h),

              /// FACULTY STATS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("complaints")
                    .where("facultyName", isEqualTo: userName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final docs = snapshot.data!.docs;
                  final pending = docs
                      .where((d) => d['status'] == 'Pending')
                      .length;
                  final progress = docs
                      .where((d) => d['status'] == 'In Progress')
                      .length;
                  final resolved = docs
                      .where((d) => d['status'] == 'Resolved')
                      .length;

                  return Wrap(
                    spacing: 2.w,
                    runSpacing: 2.h,
                    children: [
                      _statBox(
                        "Pending",
                        pending,
                        Colors.red,
                        Icons.error_outline,
                      ),
                      _statBox(
                        "In Progress",
                        progress,
                        Colors.orange,
                        Icons.sync,
                      ),
                      _statBox(
                        "Resolved",
                        resolved,
                        Colors.green,
                        Icons.check_circle_outline,
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 3.h),

              Text(
                "Your Complaints",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 1.h),

              /// STATUS FILTER
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Filter by Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All")),
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),
                  DropdownMenuItem(
                    value: "In Progress",
                    child: Text("In Progress"),
                  ),
                  DropdownMenuItem(value: "Resolved", child: Text("Resolved")),
                ],
                onChanged: (value) {
                  setLocalState(() => selectedStatus = value!);
                },
              ),

              SizedBox(height: 2.h),

              /// COMPLAINT LIST
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("complaints")
                    .where("facultyName", isEqualTo: userName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final complaints =
                      snapshot.data!.docs.where((doc) {
                        if (selectedStatus == "all") return true;
                        return doc['status'] == selectedStatus;
                      }).toList()..sort((a, b) {
                        final t1 = a['timestamp'] as Timestamp?;
                        final t2 = b['timestamp'] as Timestamp?;
                        // Descending: latest first
                        return (t2?.millisecondsSinceEpoch ?? 0).compareTo(
                          t1?.millisecondsSinceEpoch ?? 0,
                        );
                      });

                  if (complaints.isEmpty) {
                    return const Text("No complaints found");
                  }

                  return Column(
                    children: complaints
                        .map(
                          (doc) => _complaintCard(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itTechnicianDashboard() {
    String selectedStatus = "all";
    String selectedLab = "all";
    List<String> technicianLabs = [];

    return StatefulBuilder(
      builder: (context, setLocalState) {
        // Fetch technician labs once
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && technicianLabs.isEmpty) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get()
              .then((doc) {
                final labs = List<String>.from(
                  doc.data()?['associatedLabs'] ?? [],
                );
                if (labs.isNotEmpty) {
                  setLocalState(() {
                    technicianLabs = labs;
                  });
                }
              });
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),
              SizedBox(height: 3.h),

              /// IT STATS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("complaints")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final docs = snapshot.data!.docs;
                  return Wrap(
                    spacing: 2.w,
                    runSpacing: 2.h,
                    children: [
                      _statBox(
                        "Pending",
                        docs.where((d) => d['status'] == 'Pending').length,
                        Colors.red,
                        Icons.error_outline,
                      ),
                      _statBox(
                        "In Progress",
                        docs.where((d) => d['status'] == 'In Progress').length,
                        Colors.orange,
                        Icons.sync,
                      ),
                      _statBox(
                        "Resolved",
                        docs.where((d) => d['status'] == 'Resolved').length,
                        Colors.green,
                        Icons.check_circle_outline,
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 3.h),

              /// FILTERS
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "all", child: Text("All")),
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                        DropdownMenuItem(
                          value: "In Progress",
                          child: Text("In Progress"),
                        ),
                        DropdownMenuItem(
                          value: "Resolved",
                          child: Text("Resolved"),
                        ),
                      ],
                      onChanged: (v) =>
                          setLocalState(() => selectedStatus = v!),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedLab,
                      decoration: const InputDecoration(
                        labelText: "Lab",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: "all",
                          child: Text("All Labs"),
                        ),
                        ...technicianLabs.map(
                          (lab) =>
                              DropdownMenuItem(value: lab, child: Text(lab)),
                        ),
                      ],
                      onChanged: (v) => setLocalState(() => selectedLab = v!),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              /// COMPLAINT LIST
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("complaints")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final complaints =
                      snapshot.data!.docs.where((doc) {
                        final statusMatch =
                            selectedStatus == "all" ||
                            doc['status'] == selectedStatus;
                        final labMatch =
                            selectedLab == "all" || doc['lab'] == selectedLab;
                        return statusMatch && labMatch;
                      }).toList()..sort((a, b) {
                        final t1 = a['timestamp'] as Timestamp?;
                        final t2 = b['timestamp'] as Timestamp?;
                        // Descending: latest first
                        return (t2?.millisecondsSinceEpoch ?? 0).compareTo(
                          t1?.millisecondsSinceEpoch ?? 0,
                        );
                      });

                  if (complaints.isEmpty) {
                    return const Text("No complaints found");
                  }

                  return Column(
                    children: complaints
                        .map(
                          (doc) => _complaintCard(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == "admin";

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Admin Dashboard" : "Dashboard"),
        centerTitle: true,
        actions: [
          if (role.toLowerCase() == "it technician")
            IconButton(
              tooltip: "Manage Labs",
              icon: const Icon(Icons.computer),
              onPressed: () {
                Navigator.pushNamed(context, Routes.labList);
              },
            ),
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _logout,
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsivePadding(context),
          ),
          child: isAdmin
              ? Column(
                  children: [
                    _welcomeCard(),
                    SizedBox(height: 3.h),

                    // --- ADMIN REAL-TIME STATS START ---

                    // 1. Stream for Users Collection
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        // 2. Stream for Complaints Collection
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('complaints')
                              .snapshots(),
                          builder: (context, complaintSnapshot) {
                            // Handling Loading State
                            if (!userSnapshot.hasData ||
                                !complaintSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            // --- CALCULATING DATA ---
                            final userDocs = userSnapshot.data!.docs;
                            final complaintDocs = complaintSnapshot.data!.docs;

                            // Users Stats
                            final totalUsers = userDocs.length;
                            final waitingApproval = userDocs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              // Check if 'isApproved' exists and is false
                              return data.containsKey('isApproved') &&
                                  data['isApproved'] == false;
                            }).length;

                            // Complaints Stats
                            final totalComplaints = complaintDocs.length;
                            final resolvedCount = complaintDocs
                                .where((d) => d['status'] == 'Resolved')
                                .length;
                            final pendingCount = complaintDocs
                                .where((d) => d['status'] == 'Pending')
                                .length;
                            final progressCount = complaintDocs
                                .where((d) => d['status'] == 'In Progress')
                                .length;

                            // --- DISPLAYING CARDS ---
                            return Wrap(
                              spacing: 2.w,
                              runSpacing: 2.h,
                              alignment: WrapAlignment.center,
                              children: [
                                _statBox(
                                  "Total Users",
                                  totalUsers,
                                  Colors.blue,
                                  Icons.people,
                                ),
                                _statBox(
                                  "Waiting Approval",
                                  waitingApproval,
                                  Colors.teal,
                                  Icons.hourglass_empty,
                                ),
                                _statBox(
                                  "Total Complaints",
                                  totalComplaints,
                                  Colors.purple,
                                  Icons.report_problem,
                                ),
                                _statBox(
                                  "Resolved",
                                  resolvedCount,
                                  Colors.green,
                                  Icons.check_circle,
                                ),
                                _statBox(
                                  "In Progress",
                                  progressCount,
                                  Colors.orange,
                                  Icons.sync,
                                ),
                                _statBox(
                                  "Pending",
                                  pendingCount,
                                  Colors.red,
                                  Icons.error,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // --- ADMIN REAL-TIME STATS END ---
                    SizedBox(height: 4.h),
                    _dashboardButton(
                      "Manage Users",
                      "Add, edit or remove users",
                      Icons.group,
                      () => Navigator.pushNamed(context, Routes.manageUsers),
                      Colors.teal,
                    ),
                    SizedBox(height: 2.h),
                    _dashboardButton(
                      "Filter Complaints",
                      "Smart multi-layer filtering",
                      Icons.filter_list,
                      () =>
                          Navigator.pushNamed(context, Routes.filterComplaints),
                      Colors.deepPurple,
                    ),
                    SizedBox(height: 2.h),
                    _dashboardButton(
                      "Manage Labs",
                      "View and Edit Labs",
                      Icons.laptop_chromebook,
                      () => Navigator.pushNamed(context, Routes.labList),
                      Colors.blueAccent,
                    ),
                  ],
                )
              : role.toLowerCase() == "faculty"
              ? _facultyDashboard()
              : _itTechnicianDashboard(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.chat),
        onPressed: () => Navigator.pushNamed(context, Routes.chats),
      ),
    );
  }

  Widget _complaintCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Unknown';

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 1.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to complaint detail if needed
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsivePadding(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['issue'] ?? 'Issue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                "Category: ${data['issueCategory'] ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                data['message'] ?? '',
                style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 3.w,
                runSpacing: 0.8.h,
                children: [
                  _infoChip(Icons.location_on, data['lab'] ?? 'Unknown Lab'),
                  _infoChip(Icons.person, data['facultyName'] ?? 'Unknown'),
                  if ((data['resolvedByName'] ?? '').toString().isNotEmpty)
                    _infoChip(Icons.check_circle, data['resolvedByName']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        SizedBox(width: 1.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
