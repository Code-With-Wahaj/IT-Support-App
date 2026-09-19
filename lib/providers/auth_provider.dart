import 'dart:developer';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool loading = false;

  AuthProvider() {
    // Load current user at provider creation
    user = _authService.currentUser;

    // 🔥 Auth state listener with approval enforcement
    FirebaseAuth.instance.authStateChanges().listen((User? u) async {
      user = u;
      notifyListeners();

      if (user != null) {
        try {
          final doc = await _authService.getUserDoc(user!.uid);
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final isApproved = data['isApproved'] ?? false;

          if (!isApproved) {
            await _authService.logout();
            user = null;
            notifyListeners();
          }
        } catch (_) {
          await _authService.logout();
          user = null;
          notifyListeners();
        }
      }
    });
  }

  // ---------------- LOGIN ----------------

  Future<String?> login(String email, String password) async {
    loading = true;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result == null) {
      user = _authService.currentUser;

      if (user != null) {
        try {

          final doc = await _authService.getUserDoc(user!.uid);
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final isApproved = data['isApproved'] ?? false;

          if (!isApproved) {
            await _authService.logout();
            user = null;
            loading = false;
            notifyListeners();
            return "Account registered successfully.\nWaiting for admin approval.";
          }
        } catch (_) {
          await _authService.logout();
          user = null;
          loading = false;
          notifyListeners();
          return "Failed to verify account approval.";
        }
      }
    }

    loading = false;
    notifyListeners();
    return result;
  }

  // ---------------- SIGNUP ----------------
  /// 🔥 IMPORTANT:
  /// - User is ALWAYS logged out after signup
  /// - Prevents auto-login
  /// - Prevents stuck loader
  /// - UI shows success dialog/snackbar
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    List<String>? associatedLabs,
    bool isApproved = false,
  }) async {
    loading = true;
    notifyListeners();

    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
      associatedLabs: associatedLabs,
      isApproved: isApproved,
    );

    // 🔥 ALWAYS LOGOUT AFTER SIGNUP
    await _authService.logout();
    user = null;

    loading = false;
    notifyListeners();

    return result; // null = success
  }

  // ---------------- LOGOUT ----------------

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }

  bool get isLoggedIn => user != null;

  // ---------------- ADMIN HELPERS ----------------

  Stream<QuerySnapshot> usersStream() =>
      _authService.fetchUsersStream();

  Future<void> adminUpdateUserDoc(
      String uid, Map<String, dynamic> data) =>
      _authService.updateUserDoc(uid, data);

  Future<void> adminSetApproval(String uid, bool isApproved) =>
      _authService.setApproval(uid, isApproved);

  Future<void> adminDeleteFirestoreUser(String uid) =>
      _authService.deleteUserFirestoreOnly(uid);
}
