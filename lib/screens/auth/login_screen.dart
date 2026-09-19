
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_text_button.dart';
import '../../widgets/animations/network_background.dart';
import '../../widgets/animations/glass_card.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
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
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                                      "SYSTEM ACCESS",
                                      style: TextStyle(
                                        color: AppTheme.accentColor,
                                        fontSize: 10.sp,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      "Welcome Back",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomTextField(
                                      label: "Email",
                                      hint: "Enter your email address",
                                      controller: emailC,
                                      prefixIcon: Icons.email_outlined,
                                    ),
                                    SizedBox(height: 2.5.h),
                                    CustomTextField(
                                      label: "Password",
                                      hint: "Enter your password",
                                      controller: passC,
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomButton(
                                      text: authProvider.loading
                                          ? "Authenticating..."
                                          : "Login",
                                      onTap: authProvider.loading
                                          ? () {}
                                          : () async {
                                              if (!_formKey.currentState!
                                                  .validate())
                                                return;
                                              FocusScope.of(context).unfocus();
                                              final result = await authProvider
                                                  .login(
                                                    emailC.text.trim(),
                                                    passC.text.trim(),
                                                  );
                                              if (context.mounted) {
                                                if (result == null) {
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    Routes.dashboard,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(result),
                                                      backgroundColor:
                                                          AppTheme.errorColor,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration: const Duration(
                                                        seconds: 4,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                    ),
                                    SizedBox(height: 3.h),
                                    CustomTextButton(
                                      text: "Forgot Password?",
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        Routes.forgot,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Image.asset(asset, width: size, height: size),
    );
  }
}
