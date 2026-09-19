import 'package:flutter/material.dart';
import 'package:aptech_it_support/screens/admin/manage_users_screen.dart';
import 'package:aptech_it_support/screens/chats/chats_screen.dart';
import 'package:aptech_it_support/screens/dashboard/filter_complaints.dart';
import 'package:aptech_it_support/screens/labs/lab_list_screen.dart';
import '../screens/admin/admin_add_user.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgot = '/forgot';
  static const String dashboard = '/dashboard';
  static const String chats = '/chats';
  static const String filterComplaints = '/filter_complaints';
  static const String complaintDetail = '/complaint_detail';
  static const String adminAddUser = '/admin_add_user';
  static const String manageUsers = '/manage_users';
  static const String labList = '/lab_list';
}

final Map<String, Widget Function(BuildContext)> routes = {
  Routes.splash: (_) => const SplashScreen(),
  Routes.login: (_) => LoginScreen(),
  Routes.signup: (_) => SignupScreen(),
  Routes.forgot: (_) => const ForgotPasswordScreen(),
  Routes.dashboard: (_) => const DashboardScreen(),
  Routes.chats: (_) => const ChatScreen(),
  Routes.filterComplaints: (_) => const FilterComplaintsScreen(),
  Routes.adminAddUser: (_) => const AdminAddUserScreen(),
  Routes.manageUsers: (_) => const ManageUsersScreen(),
  Routes.labList: (_) => const LabListScreen(),
};
