
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aptech_it_support/widgets/custom_button.dart';
import 'package:aptech_it_support/widgets/custom_text_button.dart';
import 'package:aptech_it_support/widgets/custom_textfield.dart';
import 'package:aptech_it_support/widgets/animations/network_background.dart';
import 'package:aptech_it_support/widgets/animations/glass_card.dart';
import 'package:aptech_it_support/theme/app_theme.dart';
import 'package:aptech_it_support/utils/responsive_utils.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final emailC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entryAnimationController.forward();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    emailC.dispose();
    super.dispose();
  }

  // --- LOGIC STARTS HERE ---
  resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailC.text.trim(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Password reset link dispatched! Please check your email inbox.",
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        emailC.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        String msg = "Failed to send reset link.";
        if (e.code == 'user-not-found') {
          msg = "No registered account found with this email.";
        } else if (e.code == 'invalid-email') {
          msg = "The email address is improperly formatted.";
        } else if (e.code == 'too-many-requests') {
          msg = "Too many reset requests. Please wait a few moments.";
        } else if (e.code == 'network-request-failed') {
          msg = "Network error. Please check your internet connection.";
        } else if (e.message != null && e.message!.isNotEmpty) {
          msg = e.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    if (context.mounted) {
      setState(() => loading = false);
    }
  }
  // --- LOGIC ENDS HERE ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
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
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 4.h : 3.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ResponsiveWrapper(
                    maxWidth: 500,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLogo('assets/aptech_logo.png', context),
                        _buildLogo('assets/logo.png', context),
                      ],
                    ),
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
                        maxWidth: 500,
                        padding: EdgeInsets.zero,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: GlassCard(
                              backgroundColor: AppTheme.primaryLight
                                  .withOpacity(0.6),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "FORGOT PASSWORD",
                                      style: TextStyle(
                                        color: AppTheme.accentColor,
                                        fontSize: 10.sp,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      "Recover Your Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "Enter your email address and we'll send you a link to reset your password.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12.sp,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomTextField(
                                      label: "Email",
                                      hint: "Enter your registered email",
                                      controller: emailC,
                                      prefixIcon: Icons.email_outlined,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Email is required";
                                        }
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(v.trim())) {
                                          return "Enter a valid email address";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomButton(
                                      text: loading
                                          ? "Sending Reset Link..."
                                          : "Send Reset Link",
                                      onTap: loading ? () {} : resetPassword,
                                    ),
                                    SizedBox(height: 3.h),
                                    CustomTextButton(
                                      text: "Back to Login",
                                      onTap: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
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
    final size = ResponsiveUtils.isMobile(context) ? 14.w : 60.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
      ),
    );
  }
}
