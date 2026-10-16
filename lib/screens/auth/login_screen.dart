import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_text_button.dart';
import '../../widgets/expressive_logo.dart';
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

  @override
  void initState() {
    super.initState();
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOut,
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ResponsiveWrapper(
                    maxWidth: 480,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Image.asset(
                            'assets/aptech_logo.png',
                            width: 48,
                            height: 48,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.school, color: Colors.white),
                          ),
                        ),
                        const ExpressiveAppLogo(size: 50, showBadgeText: true),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsivePadding(context),
                        vertical: 16,
                      ),
                      child: ResponsiveWrapper(
                        maxWidth: 480,
                        padding: EdgeInsets.zero,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: GlassCard(
                            backgroundColor: AppTheme.primaryLight.withOpacity(0.75),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "AUTHORIZED PERSONNEL PORTAL",
                                      style: TextStyle(
                                        color: AppTheme.accentGlow,
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Sign In to IT Hub",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Use your admin-approved Aptech credentials",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  CustomTextField(
                                    label: "Work Email",
                                    hint: "name@aptech-education.com.pk",
                                    controller: emailC,
                                    prefixIcon: Icons.email_outlined,
                                  ),
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    label: "Password",
                                    hint: "Enter your password",
                                    controller: passC,
                                    prefixIcon: Icons.lock_outline,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 28),
                                  CustomButton(
                                    text: authProvider.loading
                                        ? "Verifying Access..."
                                        : "Sign In",
                                    onTap: authProvider.loading
                                        ? () {}
                                        : () async {
                                            if (!_formKey.currentState!.validate()) {
                                              return;
                                            }
                                            FocusScope.of(context).unfocus();
                                            final result = await authProvider.login(
                                              emailC.text.trim(),
                                              passC.text.trim(),
                                            );
                                            if (!context.mounted) return;
                                            if (result == null) {
                                              final uid = authProvider.user?.uid;
                                              if (uid != null) {
                                                await context
                                                    .read<AppDataProvider>()
                                                    .bindSessionStreams(uid);
                                              }
                                              if (!context.mounted) return;
                                              Navigator.pushReplacementNamed(
                                                context,
                                                Routes.dashboard,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(result),
                                                  backgroundColor:
                                                      AppTheme.errorColor,
                                                ),
                                              );
                                            }
                                          },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                          context,
                                          Routes.onboarding,
                                        ),
                                        icon: const Icon(
                                          Icons.auto_fix_high,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                        label: const Text(
                                          "App Intro",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      CustomTextButton(
                                        text: "Forgot Password?",
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          Routes.forgot,
                                        ),
                                      ),
                                    ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
