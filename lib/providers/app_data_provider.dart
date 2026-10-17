import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Delta-Sync & Local Cache Provider.
/// Eliminates duplicate StreamBuilders and caches all complaints/chats locally on device
/// so switching screens or sending messages only reads incremental changes from Firestore!
class AppDataProvider extends ChangeNotifier {
  static const String _cacheKey = 'cached_complaints_v2';
  static const String _userProfileCacheKey = 'cached_user_profile_v2';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Map of complaintId -> `Map<String, dynamic>` (sorted newest or oldest as needed)
  final Map<String, Map<String, dynamic>> _complaintsMap = {};
  Map<String, dynamic>? _currentUserProfile;

  StreamSubscription<QuerySnapshot>? _deltaSubscription;
  StreamSubscription<QuerySnapshot>? _usersSummarySubscription;

  bool isInitialized = false;
  int totalUsersCount = 0;
  int waitingApprovalCount = 0;

  // Lazy Loading & Pagination State (10 complaints per page)
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMoreComplaints = true;
  DocumentSnapshot? _lastVisibleDoc;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreComplaints => _hasMoreComplaints;

  /// Returns complaints sorted newest-first (for Dashboard)
  List<Map<String, dynamic>> get complaintsNewestFirst {
    final list = _complaintsMap.values.toList();
    list.sort((a, b) => (b['timestampMs'] as int? ?? 0).compareTo(a['timestampMs'] as int? ?? 0));
    return list;
  }

  /// Returns complaints sorted oldest-first (for Group Chat chronological view)
  List<Map<String, dynamic>> get complaintsOldestFirst {
    final list = _complaintsMap.values.toList();
    list.sort((a, b) => (a['timestampMs'] as int? ?? 0).compareTo(b['timestampMs'] as int? ?? 0));
    return list;
  }

  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  String get userName => (_currentUserProfile?['name'] ?? '').toString();
  String get userRole => (_currentUserProfile?['role'] ?? '').toString();
  List<String> get associatedLabs =>
      List<String>.from(_currentUserProfile?['associatedLabs'] ?? []);

  bool get isSuperAdmin {
    final email = (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase().trim();
    final r = userRole.toLowerCase().trim();
    return r == 'super admin' ||
        r == 'superadmin' ||
        _currentUserProfile?['isSuperAdmin'] == true ||
        email == 'wahajaamir2@gmail.com' ||
        email == 'cah-sf@aptech-education.com.pk';
  }

  bool get isAdmin => userRole.toLowerCase().trim() == 'admin' || isSuperAdmin;

  /// 1. Load cached complaints & profile immediately from local storage (0 Firebase reads)
  Future<void> initializeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawComplaints = prefs.getString(_cacheKey);
      if (rawComplaints != null && rawComplaints.isNotEmpty) {
        final decoded = jsonDecode(rawComplaints) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          _complaintsMap[k] = Map<String, dynamic>.from(v as Map);
        });
      }

      final rawUser = prefs.getString(_userProfileCacheKey);
      if (rawUser != null && rawUser.isNotEmpty) {
        _currentUserProfile = Map<String, dynamic>.from(jsonDecode(rawUser));
      }
    } catch (e) {
      debugPrint('Local cache load warning: $e');
    }

    isInitialized = true;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        bindSessionStreams(user.uid);
      } else {
        disposeStreams();
      }
    });
  }

  /// 2. Attach single shared Firestore listener using DocumentChanges delta updates (limited to 10 newest)
  Future<void> bindSessionStreams(String uid) async {
    // Load user profile once and cache locally
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUserProfile = _sanitizeMap(doc.data()!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userProfileCacheKey, jsonEncode(_currentUserProfile));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user doc: $e');
    }

    // Cancel any existing subscription before starting a single shared listener
    await _deltaSubscription?.cancel();
    _lastVisibleDoc = null;
    _hasMoreComplaints = true;

    // Enable Firestore persistence + listen only to the latest 10 complaints
    _deltaSubscription = _db
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize)
        .snapshots(includeMetadataChanges: false)
        .listen((snapshot) async {
      bool changed = false;

      if (snapshot.docs.isNotEmpty && _lastVisibleDoc == null) {
        _lastVisibleDoc = snapshot.docs.last;
      }

      for (final change in snapshot.docChanges) {
        final docId = change.doc.id;
        // Don't remove documents when they naturally fall outside the limit(10) window
        if (change.type != DocumentChangeType.removed) {
          final data = change.doc.data();
          if (data != null) {
            final sanitized = _sanitizeMap(data);
            sanitized['complaintId'] = docId;
            _complaintsMap[docId] = sanitized;
            changed = true;
          }
        }
      }

      if (changed) {
        notifyListeners();
        _persistComplaintsToDisk();
      }
    });

    // If Admin, maintain a lightweight listener for user counts
    if (isAdmin) {
      await _usersSummarySubscription?.cancel();
      _usersSummarySubscription = _db.collection('users').snapshots().listen((snap) {
        totalUsersCount = snap.docs.length;
        waitingApprovalCount = snap.docs.where((d) {
          final data = d.data();
          return data.containsKey('isApproved') && data['isApproved'] == false;
        }).length;
        notifyListeners();
      });
    }
  }

  /// Lazy load next batch of older complaints on demand as user scrolls
  Future<void> loadMoreComplaints() async {
    if (_isLoadingMore || !_hasMoreComplaints) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      Query query = _db
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);

      if (_lastVisibleDoc != null) {
        query = query.startAfterDocument(_lastVisibleDoc!);
      }

      final snap = await query.get();
      if (snap.docs.isEmpty) {
        _hasMoreComplaints = false;
      } else {
        _lastVisibleDoc = snap.docs.last;
        if (snap.docs.length < _pageSize) {
          _hasMoreComplaints = false;
        }
        for (final doc in snap.docs) {
          final docId = doc.id;
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final sanitized = _sanitizeMap(data);
            sanitized['complaintId'] = docId;
            _complaintsMap[docId] = sanitized;
          }
        }
        await _persistComplaintsToDisk();
      }
    } catch (e) {
      debugPrint('Error loading more complaints: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Optimistic local insert so sent chat messages appear in 0ms before server roundtrip
  void upsertLocalComplaint(String id, Map<String, dynamic> rawData) {
    final sanitized = _sanitizeMap(rawData);
    sanitized['complaintId'] = id;
    _complaintsMap[id] = sanitized;
    notifyListeners();
    _persistComplaintsToDisk();
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((key, value) {
      if (value is Timestamp) {
        out[key] = value.millisecondsSinceEpoch;
        if (key == 'timestamp') {
          out['timestampMs'] = value.millisecondsSinceEpoch;
        }
      } else if (value is DateTime) {
        out[key] = value.millisecondsSinceEpoch;
      } else {
        out[key] = value;
      }
    });
    if (!out.containsKey('timestampMs')) {
      final ts = out['timestamp'];
      out['timestampMs'] = ts is int ? ts : DateTime.now().millisecondsSinceEpoch;
    }
    return out;
  }

  Future<void> _persistComplaintsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(_complaintsMap));
    } catch (e) {
      debugPrint('Persist cache error: $e');
    }
  }

  void disposeStreams() {
    _deltaSubscription?.cancel();
    _deltaSubscription = null;
    _usersSummarySubscription?.cancel();
    _usersSummarySubscription = null;
    _lastVisibleDoc = null;
  }
}
