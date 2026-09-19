import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aptech_it_support/screens/admin/user_dialogs.dart';
import 'package:aptech_it_support/theme/app_theme.dart';
import 'package:aptech_it_support/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:sizer/sizer.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Manage Users"),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.school, color: Colors.white),
                  child: Text("Faculty", style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  icon: Icon(Icons.engineering, color: Colors.white),
                  child: Text(
                    "IT Technician",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              UserListTab(role: "Faculty"),
              UserListTab(role: "IT Technician"),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentColor,
            icon: const Icon(Icons.person_add),
            label: const Text("Add User"),
            onPressed: () {
              Navigator.pushNamed(context, '/admin_add_user');
            },
          ),
        ),
      ),
    );
  }
}

class UserListTab extends StatelessWidget {
  final String role;
  const UserListTab({required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    return ResponsiveWrapper(
      child: StreamBuilder<QuerySnapshot>(
        stream: authProv.usersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs
              .where((d) => (d['role'] ?? '') == role)
              .toList();

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No $role users found",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Add users using the button below",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(context),
            ),
            itemCount: docs.length,
            itemBuilder: (context, idx) {
              final d = docs[idx];
              final data = d.data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final email = data['email'] ?? '';
              final isApproved = data['isApproved'] ?? false;
              final associatedLabs = List<String>.from(
                data['associatedLabs'] ?? [],
              );

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsivePadding(
                      context,
                      mobile: 12,
                      tablet: 16,
                      desktop: 16,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.accentColor,
                            radius: 24,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isApproved
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                            child: Text(
                              isApproved ? "Approved" : "Pending",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isApproved
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (associatedLabs.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 0.5.h,
                          children: associatedLabs
                              .map(
                                (lab) => Chip(
                                  label: Text(lab),
                                  backgroundColor: AppTheme.accentColor
                                      .withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 13.sp,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      SizedBox(height: 1.h),
                      Divider(color: AppTheme.textTertiary.withOpacity(0.2)),
                      SizedBox(height: 0.5.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.5.h,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text("View"),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) =>
                                  UserDetailDialog(docId: d.id, data: data),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit"),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) =>
                                  EditUserDialog(docId: d.id, initial: data),
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              isApproved ? Icons.block : Icons.check_circle,
                              size: 18,
                            ),
                            label: Text(isApproved ? "Revoke" : "Approve"),
                            style: TextButton.styleFrom(
                              foregroundColor: isApproved
                                  ? AppTheme.warningColor
                                  : AppTheme.successColor,
                            ),
                            onPressed: () async {
                              await authProv.adminSetApproval(
                                d.id,
                                !isApproved,
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text("Delete"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: AppTheme.errorColor,
                                      ),
                                      SizedBox(width: 2.w),
                                      const Text("Confirm Deletion"),
                                    ],
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete user '$name'?\n\nThis will remove the Firestore document and auth account (if available).",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                              if (ok ?? false) {
                                try {
                                  await authProv.adminDeleteFirestoreUser(d.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "User deleted successfully",
                                        ),
                                        backgroundColor: AppTheme.successColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Delete failed: $e"),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
