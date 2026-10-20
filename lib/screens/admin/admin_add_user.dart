import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/route_guard.dart';
import 'package:sizer/sizer.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});
  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  String selectedRole = "Faculty";
  List<String> roles = ["Faculty", "IT Technician"];
  bool isSuperAdmin = false;
  final labC = TextEditingController();
  List<String> associatedLabs = [];

  @override
  void initState() {
    super.initState();
    _checkSuperAdmin();
  }

  Future<void> _checkSuperAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final email = (user.email ?? '').toLowerCase().trim();
    if (email == 'wahajaamir2@gmail.com' ||
        email == 'cah-sf@aptech-education.com.pk' ||
        email == 'academicsfc@gmail.com') {
      if (mounted) {
        setState(() {
          isSuperAdmin = true;
          roles = ["Faculty", "IT Technician", "Admin", "Super Admin"];
        });
      }
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final r = (doc.data()?['role'] ?? '').toString().toLowerCase().trim();
      final isSA = doc.data()?['isSuperAdmin'] == true;
      if (mounted) {
        setState(() {
          isSuperAdmin = r == 'super admin' ||
              r == 'superadmin' ||
              isSA ||
              email == 'wahajaamir2@gmail.com' ||
              email == 'cah-sf@aptech-education.com.pk' ||
              email == 'academicsfc@gmail.com';
          if (isSuperAdmin) {
            roles = ["Faculty", "IT Technician", "Admin", "Super Admin"];
          }
        });
      }
    } catch (_) {}
  }

  bool validateLab(String raw) {
    raw = raw.toUpperCase();
    if (raw == "JBR" || raw == "IBR") return true;
    final n = int.tryParse(raw);
    if (n != null) {
      if ((n >= 101 && n <= 110) || (n >= 201 && n <= 220)) return true;
    }
    return false;
  }

  void addLab() {
    final raw = labC.text.trim().toUpperCase();
    if (!validateLab(raw)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid lab")));
      return;
    }
    final formatted = raw == "JBR"
        ? "JBR Lab"
        : raw == "IBR"
        ? "IBR Lab"
        : "Lab $raw";
    if (!associatedLabs.contains(formatted)) {
      setState(() => associatedLabs.add(formatted));
    }
    labC.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    return AdminScreenGuard(
      child: SafeArea(
        child: Scaffold(
        appBar: AppBar(title: Text(isSuperAdmin ? "Add User / Admin" : "Add User")),
        body: Padding(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 2.h),
                CustomTextField(
                  textcolor: Colors.black,
                  label: "Name",
                  hint: "Name",
                  controller: nameC,
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 1.h),
                CustomTextField(
                  textcolor: Colors.black,
                  label: "Email",
                  hint: "Email",
                  controller: emailC,
                  prefixIcon: Icons.email,
                ),
                SizedBox(height: 1.h),
                CustomTextField(
                  textcolor: Colors.black,
                  label: "Password",
                  hint: "Password",
                  controller: passC,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 1.h),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRole = v!),
                  decoration: InputDecoration(
                    labelText: "Role",
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                if (selectedRole == "IT Technician") ...[
                  Wrap(
                    spacing: 6,
                    children: associatedLabs
                        .map(
                          (l) => Chip(
                            label: Text(l),
                            onDeleted: () =>
                                setState(() => associatedLabs.remove(l)),
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: labC,
                          decoration: const InputDecoration(
                            labelText: "Add Lab",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: addLab,
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 2.h),
                CustomButton(
                  text: authProv.loading ? "Please wait..." : "Create User",
                  onTap: authProv.loading
                      ? () {}
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if ((selectedRole == "Admin" || selectedRole == "Super Admin") && !isSuperAdmin) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Only Super Admin can create Admin or Super Admin accounts."),
                              ),
                            );
                            return;
                          }
                          final res = await authProv.signUp(
                            name: nameC.text.trim(),
                            email: emailC.text.trim(),
                            password: passC.text.trim(),
                            role: selectedRole,
                            associatedLabs: selectedRole == "IT Technician"
                                ? associatedLabs
                                : null,
                            isApproved: true, // admin-created -> approved
                          );
                          if (res == null) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(res)));
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
