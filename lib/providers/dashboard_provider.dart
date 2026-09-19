import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int totalUsers = 0;
  int waitingApproval = 0;
  int totalComplaints = 0;
  int resolvedComplaints = 0;
  int inProgressComplaints = 0;
  int pendingComplaints = 0;

  fetchCounts() async {
    try {
      // Users collection - count all users for admin
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      totalUsers = usersSnapshot.docs.length;
      waitingApproval = usersSnapshot.docs
          .where(
            (doc) =>
                doc['status'] != null &&
                doc['status'].toString().toLowerCase() == 'pending',
          )
          .length;

      // Complaints collection - count all complaints for admin
      final complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .get();
      totalComplaints = complaintsSnapshot.docs.length;
      resolvedComplaints = complaintsSnapshot.docs
          .where(
            (doc) =>
                doc['status'] != null &&
                doc['status'].toString().toLowerCase() == 'resolved',
          )
          .length;
      inProgressComplaints = complaintsSnapshot.docs
          .where(
            (doc) =>
                doc['status'] != null &&
                doc['status'].toString().toLowerCase() == 'in progress',
          )
          .length;
      pendingComplaints = complaintsSnapshot.docs
          .where(
            (doc) =>
                doc['status'] != null &&
                doc['status'].toString().toLowerCase() == 'pending',
          )
          .length;
    } catch (e) {
      // In case of error, reset counts to 0
      totalUsers = 0;
      waitingApproval = 0;
      totalComplaints = 0;
      resolvedComplaints = 0;
      inProgressComplaints = 0;
      pendingComplaints = 0;
    }

    notifyListeners();
  }
}
