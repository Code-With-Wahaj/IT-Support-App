import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_data_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../services/notification_service.dart';
import '../../widgets/expressive_logo.dart';
import '../../widgets/interactive_tour_overlay.dart';
import '../notifications/broadcast_notification_dialog.dart';
import 'complaint_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription? _notifSub;
  final DateTime _screenOpenTime = DateTime.now();

  // Filter Chips state (Replaces old Dropdowns & TabBars)
  String _selectedStatusChip = "All";
  String _selectedLabChip = "All Labs";
  String _selectedCategoryChip = "All";

  // Interactive Game-Style Tutorial Coach Keys
  final GlobalKey _welcomeKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _filterChipsKey = GlobalKey();
  final GlobalKey _quickActionsKey = GlobalKey();
  final GlobalKey _chatFabKey = GlobalKey();

  bool _showTour = false;

  @override
  void initState() {
    super.initState();
    _initNotificationListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstTimeTour());
  }

  Future<void> _checkFirstTimeTour() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final dataProv = context.read<AppDataProvider>();
    if (dataProv.currentUserProfile == null) {
      await dataProv.bindSessionStreams(user.uid);
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'tour_completed_${user.uid}';
    final seen = prefs.getBool(key) ?? false;
    if (!seen && mounted) {
      setState(() => _showTour = true);
    }
  }

  Future<void> _completeTour() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tour_completed_${user.uid}', true);
    }
    if (mounted) {
      setState(() => _showTour = false);
    }
  }

  void _initNotificationListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    NotificationService().requestPermission();

    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() ?? {};
            final title = (data['title'] ?? 'Notification').toString();
            final message = (data['message'] ?? '').toString();
            final complaintId = (data['complaintId'] ?? '').toString();
            final createdAt = data['createdAt'] as Timestamp?;

            if (createdAt != null &&
                createdAt.toDate().isAfter(
                  _screenOpenTime.subtract(const Duration(seconds: 5)),
                )) {
              NotificationService().showPushNotification(title, message);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$title: $message"),
                    action: SnackBarAction(
                      label: "VIEW",
                      textColor: AppTheme.accentGlow,
                      onPressed: () {
                        if (complaintId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ComplaintDetailScreen(complaintId: complaintId),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, Routes.notifications);
                        }
                      },
                    ),
                  ),
                );
              }
            }
          }
        }
      },
      onError: (e) {
        debugPrint('Notification error handled: $e');
      },
    );
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      if (!mounted) return;
      final appData = context.read<AppDataProvider>();
      final nav = Navigator.of(context);
      await appData.clearSession();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      nav.pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final isAdmin = appData.isAdmin;
    final isSuperAdmin = appData.isSuperAdmin;
    final role = appData.userRole;
    final userName = appData.userName;

    // Filter complaints locally from cached memory (Zero extra Firebase reads!)
    final allComplaints = appData.complaintsNewestFirst;
    final roleScopedComplaints = isAdmin
        ? allComplaints
        : role.toLowerCase() == 'faculty'
            ? allComplaints
                .where((c) => (c['facultyName'] ?? '') == userName)
                .toList()
            : allComplaints;

    final pendingCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'Pending')
        .length;
    final progressCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'In Progress')
        .length;
    final resolvedCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'Resolved')
        .length;

    final filteredComplaints = roleScopedComplaints.where((c) {
      final st = (c['status'] ?? 'Pending').toString();
      final lab = (c['lab'] ?? 'Unknown Lab').toString();
      final cat = (c['issueCategory'] ?? 'Other').toString();

      final statusOk = _selectedStatusChip == 'All' ||
          st.toLowerCase() == _selectedStatusChip.toLowerCase();
      final labOk = _selectedLabChip == 'All Labs' || lab == _selectedLabChip;
      final catOk = _selectedCategoryChip == 'All' ||
          cat.toLowerCase() == _selectedCategoryChip.toLowerCase();

      return statusOk && labOk && catOk;
    }).toList();

    final availableLabs = <String>{
      'All Labs',
      ...appData.associatedLabs,
      ...roleScopedComplaints
          .map((c) => (c['lab'] ?? '').toString())
          .where((s) => s.isNotEmpty),
    }.toList();

    final tourSteps = <TourStep>[
      TourStep(
        targetKey: _welcomeKey,
        title: "Welcome to Your Command Center",
        description:
            "This header shows your active role, approval badge, and quick status summary.",
        icon: Icons.verified_user_rounded,
      ),
      TourStep(
        targetKey: _statsKey,
        title: "Real-Time Telemetry Counters",
        description:
            "Live ticket counts update automatically using our local delta-sync cache without re-fetching unchanged documents.",
        icon: Icons.analytics_outlined,
      ),
      TourStep(
        targetKey: _quickActionsKey,
        title: "Lab Management & Workspaces",
        description:
            "Access campus lab assignments, user management, and advanced analytics.",
        icon: Icons.meeting_room_rounded,
      ),
      TourStep(
        targetKey: _filterChipsKey,
        title: "Instant Chip Filtering",
        description:
            "Filter live complaints by Status, Category, or Lab with zero delay.",
        icon: Icons.tune_rounded,
      ),
      TourStep(
        targetKey: _chatFabKey,
        title: "Live IT Support Group Chat",
        description:
            "Tap here anytime to report an issue or update ticket statuses in the offline-cached IT Hub Chat.",
        icon: Icons.forum_rounded,
      ),
    ];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const ExpressiveAppLogo(size: 34),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    isSuperAdmin
                        ? "Super Admin Console"
                        : isAdmin
                            ? "Admin Workspace"
                            : "IT Support Hub",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: "Interactive Guide Tour",
                icon: const Icon(Icons.help_outline_rounded),
                onPressed: () => setState(() => _showTour = true),
              ),
              StreamBuilder<int>(
                stream: NotificationService().getUnreadCountStream(
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return IconButton(
                    tooltip: "Notifications",
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppTheme.errorColor,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.notifications),
                  );
                },
              ),
              IconButton(
                tooltip: "Sign Out",
                icon: const Icon(Icons.logout_rounded),
                onPressed: _logout,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ResponsiveWrapper(
              child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: ResponsiveUtils.getResponsivePadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome Banner
                  Container(
                    key: _welcomeKey,
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ACTIVE SESSION • LOCAL DELTA-CACHE ENABLED",
                              style: TextStyle(
                                color: AppTheme.accentGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userName.isEmpty ? "Welcome Back" : userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSuperAdmin
                                ? Colors.amber.withOpacity(0.18)
                                : AppTheme.accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSuperAdmin
                                  ? Colors.amber
                                  : AppTheme.accentGlow,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuperAdmin
                                    ? Icons.shield_rounded
                                    : Icons.verified_user_rounded,
                                size: 16,
                                color: isSuperAdmin
                                    ? Colors.amberAccent
                                    : AppTheme.accentGlow,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSuperAdmin
                                    ? "Super Admin"
                                    : (role.isEmpty ? "Approved User" : role),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Responsive Telemetry Stat Grid
                  Container(
                    key: _statsKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final cards = <Widget>[
                          if (isAdmin) ...[
                            _buildMetricTile(
                              "Total Users",
                              appData.totalUsersCount,
                              AppTheme.infoColor,
                              Icons.people_alt_rounded,
                            ),
                            _buildMetricTile(
                              "Pending Approval",
                              appData.waitingApprovalCount,
                              Colors.teal,
                              Icons.hourglass_top_rounded,
                            ),
                          ],
                          _buildMetricTile(
                            "Pending Tickets",
                            pendingCount,
                            AppTheme.errorColor,
                            Icons.error_outline_rounded,
                          ),
                          _buildMetricTile(
                            "In Progress",
                            progressCount,
                            AppTheme.warningColor,
                            Icons.autorenew_rounded,
                          ),
                          _buildMetricTile(
                            "Resolved",
                            resolvedCount,
                            AppTheme.successColor,
                            Icons.task_alt_rounded,
                          ),
                        ];

                        final cols = isWide ? cards.length : 2;
                        final spacing = 12.0;
                        final width =
                            (constraints.maxWidth - (spacing * (cols - 1))) /
                                cols;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: cards
                              .map((c) => SizedBox(width: width, child: c))
                              .toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Quick Navigation Modules (Labs, Users, Analytics)
                  Container(
                    key: _quickActionsKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Workspace Modules",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth > 800
                                ? 3
                                : constraints.maxWidth > 520
                                    ? 2
                                    : 1;
                            final spacing = 12.0;
                            final itemW =
                                (constraints.maxWidth - (spacing * (cols - 1))) /
                                    cols;

                            final actions = <Widget>[
                              if (isAdmin ||
                                  role.toLowerCase() == 'it technician')
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Lab Management",
                                    subtitle:
                                        "Lab allocations & technician assignments",
                                    icon: Icons.meeting_room_rounded,
                                    color: AppTheme.accentColor,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.labList,
                                    ),
                                  ),
                                ),
                              if (isAdmin)
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Manage Users",
                                    subtitle:
                                        "Chip-filtered Faculty, Techs & approvals",
                                    icon: Icons.manage_accounts_rounded,
                                    color: AppTheme.secondaryColor,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.manageUsers,
                                    ),
                                  ),
                                ),
                              if (isAdmin)
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Advanced Analytics",
                                    subtitle:
                                        "Multi-layer chip filters & Excel export",
                                    icon: Icons.insights_rounded,
                                    color: Colors.teal,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.filterComplaints,
                                    ),
                                  ),
                                ),
                              if (isAdmin ||
                                  role.toLowerCase() == 'it technician')
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Broadcast Alert",
                                    subtitle:
                                        "Instant push & alerts to Everyone, Faculty or IT",
                                    icon: Icons.campaign_rounded,
                                    color: Colors.deepOrangeAccent,
                                    onTap: () =>
                                        BroadcastNotificationDialog.show(context),
                                  ),
                                ),
                            ];

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: actions,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 4. Chip-Based Ticket Feed (Replaces old Dropdowns)
                  Container(
                    key: _filterChipsKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Live Support Tickets",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              "${filteredComplaints.length} showing",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              "All",
                              "Pending",
                              "In Progress",
                              "Resolved"
                            ].map((st) {
                              final selected = _selectedStatusChip == st;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: Text(
                                    st,
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
                                      setState(() => _selectedStatusChip = st),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Category Filter Chips
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              "All",
                              "Hardware",
                              "Software",
                              "Network",
                              "Exam",
                              "Access",
                              "Other"
                            ].map((cat) {
                              final selected = _selectedCategoryChip == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  showCheckmark: false,
                                  label: Text(
                                    cat == "All" ? "All Categories" : cat,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: AppTheme.primaryColor,
                                  onSelected: (_) => setState(
                                    () => _selectedCategoryChip = cat,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Lab Filter Chips (if multiple labs available)
                        if (availableLabs.length > 1) ...[
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: availableLabs.map((lab) {
                                final selected = _selectedLabChip == lab;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    showCheckmark: false,
                                    avatar: Icon(
                                      Icons.computer,
                                      size: 15,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                    label: Text(
                                      lab,
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
                                        setState(() => _selectedLabChip = lab),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Filtered Tickets List
                  if (filteredComplaints.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No matching tickets for the selected chip filters",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    ...filteredComplaints.map((c) => _buildTicketCard(c)),
                    const SizedBox(height: 12),
                    if (appData.isLoadingMore)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Loading older tickets...",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (appData.hasMoreComplaints)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 12),
                          child: OutlinedButton.icon(
                            onPressed: () => appData.loadMoreComplaints(),
                            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                            label: const Text(
                              "Load More Tickets",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (filteredComplaints.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.grey.shade400),
                              const SizedBox(width: 6),
                              Text(
                                "All tickets loaded • Cached locally",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            key: _chatFabKey,
            onPressed: () => Navigator.pushNamed(context, Routes.chats),
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text("IT Hub Chat"),
          ),
        ),

        // Interactive Game-Style Coach Mark Overlay
        if (_showTour)
          InteractiveTourOverlay(
            steps: tourSteps,
            onComplete: _completeTour,
          ),
      ],
    );
  }

  Widget _buildMetricTile(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> data) {
    final status = (data['status'] ?? 'Pending').toString();
    final complaintId = (data['complaintId'] ?? '').toString();
    final statusColor = AppTheme.getStatusColor(status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: complaintId.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComplaintDetailScreen(complaintId: complaintId),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (data['issueCategory'] ?? 'General').toString(),
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (data['issue'] ?? 'Support Ticket').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                (data['message'] ?? '')
                    .toString()
                    .replaceFirst(RegExp(r'^\[.*?\]\s*'), ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _metaBadge(
                    Icons.computer_rounded,
                    (data['lab'] ?? 'Unknown Lab').toString(),
                  ),
                  _metaBadge(
                    Icons.person_outline_rounded,
                    "By: ${data['facultyName'] ?? 'Faculty'}",
                  ),
                  _metaBadge(
                    Icons.engineering_outlined,
                    "Tech: ${data['assignedToName'] ?? 'Unassigned'}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
