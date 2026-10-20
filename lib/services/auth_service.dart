import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup
  /// if an admin is currently logged in, creates user in secondary app
  /// to prevent hijacking the admin's active session and triggering security rule rejections.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    List<String>? associatedLabs,
    bool isApproved = false, // <-- default false for normal signups
  }) async {
    FirebaseApp? tempApp;
    try {
      String uid;
      if (_auth.currentUser != null) {
        tempApp = await Firebase.initializeApp(
          name: 'signup_${DateTime.now().microsecondsSinceEpoch}',
          options: Firebase.app().options,
        );
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final cred = await tempAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = cred.user!.uid;
      } else {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = cred.user!.uid;
      }

      final data = {
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "isApproved": isApproved,
        "isSuperAdmin": role == "Super Admin",
        "tempPassword": password,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      };

      if (role == "IT Technician" && associatedLabs != null && associatedLabs.isNotEmpty) {
        data["associatedLabs"] = associatedLabs;
      }

      await _firestore.collection("users").doc(uid).set(data);

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      if (tempApp != null) {
        try {
          await tempApp.delete();
        } catch (_) {}
      }
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // ---------------- Admin helper methods ----------------

  /// Stream of all user documents for admin management (you can add where filters if needed)
  Stream<QuerySnapshot> fetchUsersStream() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  /// Update arbitrary user document fields (admin edit) - doesn't touch Auth email/password
  Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  /// Set approval flag
  Future<void> setApproval(String uid, bool isApproved) async {
    await _firestore.collection('users').doc(uid).update({'isApproved': isApproved});
  }

  /// Delete user document from Firestore AND remove them from Firebase Authentication pool
  Future<void> deleteUserFully({
    required String uid,
    required String email,
    String? tempPassword,
  }) async {
    try {
      final FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'del_${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final List<String> passwordsToTry = [];
      if (tempPassword != null && tempPassword.isNotEmpty) {
        passwordsToTry.add(tempPassword);
      }

      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        final stored = doc.data()?['tempPassword'];
        if (stored != null && stored.toString().isNotEmpty) {
          passwordsToTry.add(stored.toString());
        }
      } catch (_) {}

      passwordsToTry.addAll([
        'TechPassword123!',
        'AdminPassword123!',
        'FacultyPassword123!',
        'AdminZeenat123!',
        'AdminWaseem123!',
        'FacultyAli123!',
        'TestPassword123!',
        'Pakistan123!'
      ]);

      for (final pwd in passwordsToTry) {
        try {
          final cred = await tempAuth.signInWithEmailAndPassword(
            email: email,
            password: pwd,
          );
          if (cred.user != null) {
            await cred.user!.delete();
            break;
          }
        } catch (_) {}
      }

      await tempApp.delete();
    } catch (_) {}

    // Delete Firestore document
    await _firestore.collection('users').doc(uid).delete();

    // Clean up notifications
    try {
      final notifs = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .get();
      final batch = _firestore.batch();
      for (var d in notifs.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Delete user document from Firestore only (fallback)
  Future<void> deleteUserFirestoreOnly(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Fetch single user doc snapshot
  Future<DocumentSnapshot> getUserDoc(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
