import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ComplaintService {
  final CollectionReference complaints =
  FirebaseFirestore.instance.collection('complaints');

  final User? user = FirebaseAuth.instance.currentUser;

  /// Create a new complaint with LAB + ISSUE auto-detection
  Future<void> createComplaint({required String message}) async {
    if (user == null) return;

    String complaintId = const Uuid().v4();

    /// STEP 1 — Detect LAB
    String detectedLab = _detectLab(message);

    /// STEP 2 — Remove LAB from message before checking issues
    String msgWithoutLab = message.toLowerCase().replaceAll(RegExp(r"\d+"), "");

    /// STEP 3 — Detect Issue + Category
    Map<String, String> issueData = _detectIssue(msgWithoutLab);

    /// STEP 4 — Find Technician for this lab
    QuerySnapshot techSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'IT Technician')
        .where('associatedLabs', arrayContains: detectedLab)
        .get();

    String assignedToId = 'Not Assigned';
    String assignedToName = 'Not Assigned';

    if (techSnap.docs.isNotEmpty) {
      // Assign to the first technician found
      var tech = techSnap.docs.first;
      assignedToId = tech.id;
      assignedToName = tech['name'] ?? 'Not Assigned';
    }

    /// STEP 5 — Create Complaint
    await complaints.doc(complaintId).set({
      'complaintId': complaintId,
      'facultyId': user!.uid,
      'facultyName': await _getUserName(user!.uid),
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),

      // Auto-detected additions
      'lab': detectedLab,
      'issue': issueData['issue'],
      'issueCategory': issueData['category'],

      // Assignment fields
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'status': 'Pending',
      'resolvedById': '',
      'resolvedByName': '',
      'statusUpdatedById': '',
      'statusUpdatedByName': '',
      'resolutionTimestamp': null,
      'timeTaken': null,
    });
  }

  /// Fetch User Name
  Future<String> _getUserName(String uid) async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['name'] ?? '';
  }

  // ----------------------------------------------------------------
  // LAB DETECTION
  // ----------------------------------------------------------------

  String _detectLab(String text) {
    final msg = text.toLowerCase();

    // Detect numbers within 101–120 or 201–220
    final regex = RegExp(r"\b(\d{3})\b");

    final matches = regex.allMatches(msg);

    for (var m in matches) {
      int? room = int.tryParse(m.group(0)!);
      if (room != null) {
        if ((room >= 101 && room <= 120) || (room >= 201 && room <= 220)) {
          return "Lab $room";
        }
      }
    }

    // Detect room codes like JBR, IBR
    if (msg.contains("jbr")) return "JBR Lab";
    if (msg.contains("ibr")) return "IBR Lab";

    return "Unknown Lab";
  }

  // ----------------------------------------------------------------
  // ISSUE + CATEGORY DETECTION
  // ----------------------------------------------------------------

  Map<String, String> _detectIssue(String msg) {
    msg = msg.toLowerCase();

    // EXAM (Added as requested)
    final examKeywords = [
      "activex",
      "activex issue",
      "exam",
      "exam issue",
      "exam portal",
      "exam portal issue",
      "portal issue",
      "safe exam browser",
      "seb",
    ];

    // SOFTWARE
    final softwareKeywords = [
      "lanschool",
      "software",
      "sql",
      "android studio",
      "vscode",
      "mongodb",
      "not working",
      "app crash",
      "installation",
      "screen sharing"
    ];

    // HARDWARE
    final hardwareKeywords = [
      "mouse",
      "keyboard",
      "monitor",
      "led",
      "pc", // Note: Fixed missing comma from original code
      "cpu",
      "printer",
      "hardware",
      "ram",
      "screen",
    ];

    // NETWORK
    final networkKeywords = [
      "wifi",
      "internet",
      "internet issue",
      "internet problem",
      "lan",
      "network",
      "cable",
      "not connecting",
    ];

    // ACCESS
    final accessKeywords = [
      "login",
      "password",
      "blocked",
      "access denied",
      "account",
      "credentials",
      "admin credentials",
      "admin login", // Note: Fixed missing comma from original code
      "admin password"
    ];

    // Helper function to scan keywords
    String? _find(List<String> list) {
      for (var w in list) {
        if (msg.contains(w)) return w;
      }
      return null;
    }

    // Detect exam issues (Priority check)
    final exam = _find(examKeywords);
    if (exam != null) return {"issue": exam, "category": "Exam"};

    // Detect software issues
    final soft = _find(softwareKeywords);
    if (soft != null) return {"issue": soft, "category": "Software"};

    // Detect hardware
    final hard = _find(hardwareKeywords);
    if (hard != null) return {"issue": hard, "category": "Hardware"};

    // Detect network
    final net = _find(networkKeywords);
    if (net != null) return {"issue": net, "category": "Network"};

    // Detect access/login issues
    final acc = _find(accessKeywords);
    if (acc != null) return {"issue": acc, "category": "Access"};

    // Default if nothing found
    return {"issue": "Other", "category": "Other"};
  }

  // ----------------------------------------------------------------
  // Update Status
  // ----------------------------------------------------------------
  Future<void> updateStatus({
    required String complaintId,
    required String newStatus,
    required String updaterId,
    required String updaterName,
    String? resolverId,
    String? resolverName,
  }) async {
    DocumentSnapshot doc = await complaints.doc(complaintId).get();
    Timestamp? createdAt = doc['timestamp'];
    Timestamp? resolvedAt;

    Map<String, dynamic> updateData = {
      'status': newStatus,
      'statusUpdatedById': updaterId,
      'statusUpdatedByName': updaterName,
      'resolvedById': resolverId ?? '',
      'resolvedByName': resolverName ?? '',
    };

    if (newStatus.toLowerCase() == 'resolved') {
      resolvedAt = Timestamp.now();
      updateData['resolutionTimestamp'] = resolvedAt;

      if (createdAt != null) {
        final diff = resolvedAt.toDate().difference(createdAt.toDate());
        updateData['timeTaken'] = diff.inMinutes;
      }
    }

    await complaints.doc(complaintId).update(updateData);
  }

  /// Real-time Listener (if ever needed again)
  Stream<QuerySnapshot> getComplaintsStream() {
    return complaints.orderBy('timestamp').snapshots();
  }
}