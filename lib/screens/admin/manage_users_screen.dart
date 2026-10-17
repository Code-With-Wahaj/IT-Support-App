import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../routes/route_guard.dart';
import 'user_dialogs.dart';

/// Completely TabBar-free Manage Users Screen!
/// Uses interactive ChoiceChips & FilterChips for Role, Approval Status, and Search.
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedRoleChip = "All Roles";
  String _selectedApprovalChip = "All";
  String _searchQuery = "";
  final TextEditingController _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final appData = context.watch<AppDataProvider>();
    final isSuperAdmin = appData.isSuperAdmin;

    final roleChips = <String>[
      "All Roles",
      "Faculty",
      "IT Technician",
      if (isSuperAdmin) "Admin",
    ];

    return AdminScreenGuard(
      child: Scaffold(
        appBar: AppBar(
        title: Text(isSuperAdmin ? "Manage Users & Admins" : "Manage Users"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(isSuperAdmin ? "Add User / Admin" : "Add User"),
        onPressed: () => Navigator.pushNamed(context, '/admin_add_user'),
      ),
      body: ResponsiveWrapper(
        child: StreamBuilder<QuerySnapshot>(
          stream: authProv.usersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exclude Super Admin accounts from general list
            final allDocs = snapshot.data!.docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final docRole = (data['role'] ?? '').toString().toLowerCase().trim();
              final docEmail = (data['email'] ?? '').toString().toLowerCase().trim();
              final isDocSA = data['isSuperAdmin'] == true;
              if (docEmail == 'wahajaamir2@gmail.com' ||
                  docEmail == 'cah-sf@aptech-education.com.pk' ||
                  docRole == 'super admin' ||
                  docRole == 'superadmin' ||
                  isDocSA) {
                return false;
              }
              if (!isSuperAdmin && docRole == 'admin') {
                return false;
              }
              return true;
            }).toList();

            // Apply Chip Filters & Search
            final filteredDocs = allDocs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final role = (data['role'] ?? '').toString().trim();
              final isApproved = data['isApproved'] == true;
              final name = (data['name'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();

              final roleMatch = _selectedRoleChip == "All Roles" || role == _selectedRoleChip;
              final approvalMatch = _selectedApprovalChip == "All" ||
                  (_selectedApprovalChip == "Approved" && isApproved) ||
                  (_selectedApprovalChip == "Pending" && !isApproved);
              final searchMatch = _searchQuery.isEmpty ||
                  name.contains(_searchQuery.toLowerCase()) ||
                  email.contains(_searchQuery.toLowerCase());

              return roleMatch && approvalMatch && searchMatch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Search & Filter Chips Card (No TabBar!)
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
                        controller: _searchC,
                        onChanged: (v) => setState(() => _searchQuery = v.trim()),
                        decoration: InputDecoration(
                          hintText: "Search by name or email...",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchC.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: roleChips.map((r) {
                            final selected = _selectedRoleChip == r;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(
                                  r == "Faculty"
                                      ? Icons.school_outlined
                                      : r == "IT Technician"
                                          ? Icons.engineering_outlined
                                          : r == "Admin"
                                              ? Icons.admin_panel_settings_outlined
                                              : Icons.groups_outlined,
                                  size: 16,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                label: Text(
                                  r,
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
                                    setState(() => _selectedRoleChip = r),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["All", "Approved", "Pending"].map((st) {
                            final selected = _selectedApprovalChip == st;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  "Status: $st",
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
                                onSelected: (_) =>
                                    setState(() => _selectedApprovalChip = st),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredDocs.isEmpty
                      ? const Center(
                          child: Text(
                            "No users match the selected filter chips",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, idx) {
                            final d = filteredDocs[idx];
                            final data = d.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? 'User').toString();
                            final email = (data['email'] ?? '').toString();
                            final role = (data['role'] ?? 'Faculty').toString();
                            final isApproved = data['isApproved'] == true;
                            final labs =
                                List<String>.from(data['associatedLabs'] ?? []);

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              AppTheme.accentColor.withOpacity(0.15),
                                          radius: 22,
                                          child: Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: AppTheme.accentColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                "$email • $role",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isApproved
                                                    ? AppTheme.successColor
                                                    : AppTheme.warningColor)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isApproved
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                            ),
                                          ),
                                          child: Text(
                                            isApproved ? "Approved" : "Pending",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isApproved
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (labs.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: labs
                                            .map(
                                              (l) => Chip(
                                                label: Text(l),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const Divider(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18,
                                          ),
                                          label: const Text("Details"),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => UserDetailDialog(
                                              docId: d.id,
                                              data: data,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          label: const Text("Edit"),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => EditUserDialog(
                                              docId: d.id,
                                              initial: data,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: Icon(
                                            isApproved
                                                ? Icons.block_rounded
                                                : Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          label: Text(
                                            isApproved ? "Revoke" : "Approve",
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: isApproved
                                                ? AppTheme.warningColor
                                                : AppTheme.successColor,
                                          ),
                                          onPressed: () => authProv
                                              .adminSetApproval(d.id, !isApproved),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                          ),
                                          label: const Text("Delete"),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppTheme.errorColor,
                                          ),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Delete User"),
                                                content: Text(
                                                  "Remove '$name' permanently?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppTheme.errorColor,
                                                    ),
                                                    onPressed: () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await authProv.adminDeleteUserFully(
                                                uid: d.id,
                                                email: email,
                                                tempPassword: data['tempPassword'],
                                              );
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
}
