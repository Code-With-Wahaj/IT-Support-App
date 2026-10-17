import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';
import '../theme/app_theme.dart';
import 'app_routes.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/chats/chats_screen.dart';
import '../screens/dashboard/filter_complaints.dart';
import '../screens/admin/admin_add_user.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/labs/lab_list_screen.dart';
import '../screens/notifications/notification_panel_screen.dart';
import '../screens/dashboard/complaint_detail_screen.dart';

/// Centralized Route Guard ensuring strict authentication & RBAC for web & app.
/// Completely prevents direct URL bar navigation to unauthorized or protected screens.
class AppRouteGuard {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? Routes.splash;
    final currentUser = FirebaseAuth.instance.currentUser;

    // 1. Public Routes: Accessible without active login session
    if (Routes.publicRoutes.contains(routeName)) {
      final widget = _getPublicWidget(routeName);
      return MaterialPageRoute(
        builder: (_) => widget,
        settings: settings,
      );
    }

    // 2. Authentication Enforcement:
    // If not logged in, any attempt to access internal screens routes straight to Login
    if (currentUser == null) {
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
        settings: settings,
      );
    }

    // 3. RBAC Admin Guard:
    // Any direct navigation to admin screens is strictly protected by AdminScreenGuard
    if (Routes.adminRoutes.contains(routeName)) {
      return MaterialPageRoute(
        builder: (_) => AdminScreenGuard(
          child: _getAdminWidget(routeName),
        ),
        settings: settings,
      );
    }

    // 4. Standard Authenticated Routes
    final widget = _getAuthWidget(routeName, settings);
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
    );
  }

  static Widget _getPublicWidget(String route) {
    switch (route) {
      case Routes.onboarding:
        return const OnboardingScreen();
      case Routes.login:
        return const LoginScreen();
      case Routes.forgot:
        return const ForgotPasswordScreen();
      case Routes.splash:
      default:
        return const SplashScreen();
    }
  }

  static Widget _getAdminWidget(String route) {
    switch (route) {
      case Routes.adminAddUser:
        return const AdminAddUserScreen();
      case Routes.manageUsers:
        return const ManageUsersScreen();
      default:
        return const DashboardScreen();
    }
  }

  static Widget _getAuthWidget(String route, RouteSettings settings) {
    switch (route) {
      case Routes.dashboard:
        return const DashboardScreen();
      case Routes.chats:
        return const ChatScreen();
      case Routes.filterComplaints:
        return const FilterComplaintsScreen();
      case Routes.labList:
        return const LabListScreen();
      case Routes.notifications:
        return const NotificationPanelScreen();
      case Routes.complaintDetail:
        final id = settings.arguments is String
            ? settings.arguments as String
            : (settings.arguments is Map
                ? (settings.arguments as Map)['complaintId']?.toString()
                : null);
        if (id != null && id.isNotEmpty) {
          return ComplaintDetailScreen(complaintId: id);
        }
        return const DashboardScreen();
      default:
        return const DashboardScreen();
    }
  }
}

/// Defense-in-depth visual guard.
/// Renders a 403 Forbidden Access screen if a non-admin attempts direct access.
class AdminScreenGuard extends StatelessWidget {
  final Widget child;

  const AdminScreenGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    // During browser reload while profile data initializes
    if (!appData.isInitialized && appData.currentUserProfile == null) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.accentGlow),
              SizedBox(height: 16),
              Text(
                "Verifying Security Credentials & RBAC Access...",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Verified Admin Access
    if (appData.isAdmin) {
      return child;
    }

    // 403 Forbidden Access Screen
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text("Access Denied"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gpp_bad_rounded,
                  color: AppTheme.errorColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "403 FORBIDDEN",
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Administrator Access Required",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your account (${appData.userRole.isEmpty ? 'Faculty' : appData.userRole}) does not have permission to access this administrative screen. Direct URL navigation to this route is restricted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.dashboard,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text("Return to Dashboard"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
