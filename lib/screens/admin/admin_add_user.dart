import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
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
  final roles = ["Faculty", "IT Technician"];
  final labC = TextEditingController();
  List<String> associatedLabs = [];

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
    if (!associatedLabs.contains(formatted))
      setState(() => associatedLabs.add(formatted));
    labC.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Add User")),
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
    );
  }
}
