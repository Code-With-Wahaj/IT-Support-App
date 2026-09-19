import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup
  /// if isApproved == true, user will be immediately approved (used by admin)
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    List<String>? associatedLabs,
    bool isApproved = false, // <-- default false for normal signups
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final data = {
        "uid": cred.user!.uid,
        "name": name,
        "email": email,
        "role": role,
        "isApproved": isApproved,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      };

      if (role == "IT Technician" && associatedLabs != null && associatedLabs.isNotEmpty) {
        data["associatedLabs"] = associatedLabs;
      }

      await _firestore.collection("users").doc(cred.user!.uid).set(data);

      return null;
    } catch (e) {
      return e.toString();
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

  /// Delete user document from Firestore only (Auth deletion requires Admin SDK)
  Future<void> deleteUserFirestoreOnly(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Fetch single user doc snapshot
  Future<DocumentSnapshot> getUserDoc(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
