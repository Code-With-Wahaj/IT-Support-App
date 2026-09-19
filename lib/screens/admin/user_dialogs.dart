import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class UserDetailDialog extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const UserDetailDialog({required this.docId, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final associatedLabs = List<String>.from(data['associatedLabs'] ?? []);
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor,
            child: Text(
              (data['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              data['name'] ?? 'User Details',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow("Email", data['email'] ?? 'N/A', Icons.email),
            SizedBox(height: 1.5.h),
            _buildInfoRow("Role", data['role'] ?? 'N/A', Icons.work),
            SizedBox(height: 1.5.h),
            _buildInfoRow("User ID", data['uid'] ?? 'N/A', Icons.fingerprint),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Icon(Icons.verified, size: 20, color: AppTheme.accentColor),
                SizedBox(width: 2.w),
                Text(
                  "Status:",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        (data['isApproved'] == true
                                ? AppTheme.successColor
                                : AppTheme.errorColor)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: data['isApproved'] == true
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  child: Text(
                    data['isApproved'] == true ? 'Approved' : 'Pending',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: data['isApproved'] == true
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
            if (associatedLabs.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                "Associated Labs:",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 0.5.h,
                children: associatedLabs
                    .map(
                      (l) => Chip(
                        label: Text(l),
                        backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.accentColor),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initial;
  const EditUserDialog({required this.docId, required this.initial, super.key});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController nameC;
  late TextEditingController roleC;
  List<String> labs = [];
  final TextEditingController labInputC = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.initial['name'] ?? '');
    roleC = TextEditingController(text: widget.initial['role'] ?? '');
    labs = List<String>.from(widget.initial['associatedLabs'] ?? []);
  }

  bool validateLab(String raw) {
    raw = raw.trim().toUpperCase();
    if (raw == "JBR" || raw == "IBR") return true;
    final n = int.tryParse(raw);
    if (n != null) {
      if ((n >= 101 && n <= 110) || (n >= 201 && n <= 220)) return true;
    }
    return false;
  }

  void addLab() {
    final raw = labInputC.text.trim().toUpperCase();
    if (!validateLab(raw)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid lab")));
      return;
    }
    String formatted = (raw == "JBR")
        ? "JBR Lab"
        : (raw == "IBR")
        ? "IBR Lab"
        : "Lab $raw";
    if (!labs.contains(formatted)) setState(() => labs.add(formatted));
    labInputC.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final role = widget.initial['role'] ?? '';

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Edit User"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person, color: AppTheme.accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: roleC,
              decoration: InputDecoration(
                labelText: "Role",
                prefixIcon: Icon(Icons.work, color: AppTheme.accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (role == "IT Technician") ...[
              SizedBox(height: 2.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Associated Labs",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              if (labs.isNotEmpty)
                Wrap(
                  spacing: 2.w,
                  runSpacing: 0.5.h,
                  children: labs
                      .map(
                        (l) => Chip(
                          label: Text(l),
                          backgroundColor: AppTheme.accentColor.withOpacity(
                            0.1,
                          ),
                          labelStyle: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12.sp,
                          ),
                          deleteIconColor: AppTheme.accentColor,
                          onDeleted: () => setState(() => labs.remove(l)),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: labInputC,
                      decoration: InputDecoration(
                        labelText: "Add Lab (101, JBR, etc.)",
                        hintText: "e.g., 101 or JBR",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: AppTheme.accentColor,
                      size: 32,
                    ),
                    onPressed: addLab,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final Map<String, dynamic> update = {
              "name": nameC.text.trim(),
              "role": roleC.text.trim(),
            };

            if (roleC.text.trim() == "IT Technician") {
              update["associatedLabs"] = List<String>.from(labs);
            }

            await authProv.adminUpdateUserDoc(widget.docId, update);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("User updated successfully"),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
          ),
          child: const Text("Save Changes"),
        ),
      ],
    );
  }
}
