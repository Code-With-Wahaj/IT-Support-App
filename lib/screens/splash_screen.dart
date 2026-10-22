import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animations/network_background.dart';
import '../widgets/expressive_logo.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final String? targetRoute;
  const SplashScreen({super.key, this.targetRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1600), () async {
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding_v2') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      if (user != null) {
        final destination = (widget.targetRoute != null &&
                widget.targetRoute != Routes.splash &&
                widget.targetRoute != Routes.login &&
                widget.targetRoute != Routes.onboarding)
            ? widget.targetRoute!
            : Routes.dashboard;
        Navigator.pushReplacementNamed(context, destination);
      } else if (!hasSeenOnboarding && !kIsWeb) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      } else {
        final destination = (widget.targetRoute != null &&
                Routes.publicRoutes.contains(widget.targetRoute) &&
                widget.targetRoute != Routes.splash)
            ? widget.targetRoute!
            : Routes.login;
        Navigator.pushReplacementNamed(context, destination);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
    precacheImage(const AssetImage('assets/aptech_logo.png'), context);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedNetworkBackground(
            color: AppTheme.accentGlow,
            backgroundColor: AppTheme.primaryColor,
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExpressiveAppLogo(size: 104, padding: 16, borderRadius: 24),
                    const SizedBox(height: 24),
                    const Text(
                      "Aptech Network Hub",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Smart IT Infrastructure & Lab Management",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.68),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGlow),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
