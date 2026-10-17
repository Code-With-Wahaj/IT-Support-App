import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_text_button.dart';
import '../../widgets/animations/network_background.dart';
import '../../widgets/animations/glass_card.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'package:sizer/sizer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  final labC = TextEditingController();

  String selectedRole = "Faculty";
  final List<String> roles = ["Faculty", "IT Technician"];
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Allowed: 101-110, 201-220, JBR, IBR"),
          duration: Duration(seconds: 4),
        ),
      );
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedNetworkBackground(
            color: AppTheme.accentColor,
            backgroundColor: AppTheme.primaryColor,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 3.h : 2.h),
                ResponsiveWrapper(
                  maxWidth: 600,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLogo('assets/aptech_logo.png', context),
                      _buildLogo('assets/logo.png', context),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsivePadding(
                          context,
                        ),
                        vertical: 2.h,
                      ),
                      child: ResponsiveWrapper(
                        maxWidth: 600,
                        padding: EdgeInsets.zero,
                        child: GlassCard(
                          backgroundColor: AppTheme.primaryLight.withOpacity(
                            0.6,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 10.sp,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  "Join Our System",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                CustomTextField(
                                  label: "Name",
                                  hint: "Enter your full name",
                                  controller: nameC,
                                  prefixIcon: Icons.person,
                                ),
                                SizedBox(height: 2.h),
                                CustomTextField(
                                  label: "Email",
                                  hint: "Enter your email address",
                                  controller: emailC,
                                  prefixIcon: Icons.email,
                                ),
                                SizedBox(height: 2.h),
                                CustomTextField(
                                  label: "Password",
                                  hint: "Create a strong password",
                                  controller: passC,
                                  prefixIcon: Icons.lock,
                                  isPassword: true,
                                ),
                                SizedBox(height: 2.h),
                                CustomTextField(
                                  label: "Confirm Password",
                                  hint: "Re-enter your password",
                                  controller: confirmC,
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                SizedBox(height: 2.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Select Role",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedRole,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: AppTheme.primaryLight,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                    items: roles
                                        .map(
                                          (r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(r),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedRole = v!),
                                  ),
                                ),
                                if (selectedRole == "IT Technician") ...[
                                  SizedBox(height: 3.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Associated Labs",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  if (associatedLabs.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Wrap(
                                        spacing: 2.w,
                                        runSpacing: 1.h,
                                        children: associatedLabs
                                            .map(
                                              (l) => Chip(
                                                label: Text(l),
                                                backgroundColor: AppTheme
                                                    .accentColor
                                                    .withOpacity(0.2),
                                                labelStyle: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                deleteIconColor: Colors.white,
                                                onDeleted: () => setState(
                                                  () =>
                                                      associatedLabs.remove(l),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  SizedBox(height: 1.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: labC,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Enter lab (101, JBR, etc.)",
                                              hintStyle: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: AppTheme.accentColor,
                                            size: 28,
                                          ),
                                          onPressed: addLab,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    "Valid labs: 101-110, 201-220, JBR, IBR",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 3.h),
                                CustomButton(
                                  text: authProvider.loading
                                      ? "Creating Account..."
                                      : "Sign Up",
                                  onTap: authProvider.loading
                                      ? () {}
                                      : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          if (passC.text != confirmC.text) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Passwords do not match",
                                                ),
                                                backgroundColor:
                                                    AppTheme.errorColor,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 4,
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final result = await authProvider
                                              .signUp(
                                                name: nameC.text.trim(),
                                                email: emailC.text.trim(),
                                                password: passC.text.trim(),
                                                role: selectedRole,
                                                associatedLabs: associatedLabs,
                                              );

                                          if (!context.mounted) return;

                                          if (result == null) {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => AlertDialog(
                                                backgroundColor:
                                                    AppTheme.cardColor,
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          AppTheme.successColor,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    const Text(
                                                      "Registration Successful",
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Your account has been registered successfully.\n\n"
                                                  "Please wait for admin approval before logging in.",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacementNamed(
                                                        context,
                                                        Routes.login,
                                                      );
                                                    },
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(result),
                                                backgroundColor:
                                                    AppTheme.errorColor,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 4,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                ),
                                SizedBox(height: 2.h),
                                CustomTextButton(
                                  text: "Already have an account? Login",
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    Routes.login,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String asset, BuildContext context) {
    final size = ResponsiveUtils.isMobile(context) ? 15.w : 70.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Image.asset(asset, width: size, height: size),
    );
  }
}
