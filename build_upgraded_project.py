import os
import json
import shutil
import zipfile
from pathlib import Path

# ==============================================================================
# 1. CUSTOM LOTTIE JSON ANIMATIONS (Generated from scratch)
# ==============================================================================

def create_lottie_json(primary_rgb, accent_rgb, shape_type="pulse_hub"):
    """Generates valid, smooth 60fps Lottie JSON animations for Onboarding."""
    r1, g1, b1 = primary_rgb
    r2, g2, b2 = accent_rgb
    return json.dumps({
        "v": "5.7.4",
        "fr": 60,
        "ip": 0,
        "op": 120,
        "w": 400,
        "h": 400,
        "nm": f"aptech_{shape_type}",
        "ddd": 0,
        "assets": [],
        "layers": [
            {
                "ddd": 0,
                "ind": 1,
                "ty": 4,
                "nm": "CoreBadge",
                "sr": 1,
                "ks": {
                    "o": {"a": 0, "k": 100},
                    "r": {
                        "a": 1,
                        "k": [
                            {"t": 0, "s": [0], "e": [360], "i": {"x": [0.4], "y": [1]}, "o": {"x": [0.6], "y": [0]}},
                            {"t": 120, "s": [360]}
                        ]
                    },
                    "p": {"a": 0, "k": [200, 200, 0]},
                    "a": {"a": 0, "k": [0, 0, 0]},
                    "s": {
                        "a": 1,
                        "k": [
                            {"t": 0, "s": [92, 92, 100], "e": [108, 108, 100], "i": {"x": [0.5], "y": [1]}, "o": {"x": [0.5], "y": [0]}},
                            {"t": 60, "s": [108, 108, 100], "e": [92, 92, 100], "i": {"x": [0.5], "y": [1]}, "o": {"x": [0.5], "y": [0]}},
                            {"t": 120, "s": [92, 92, 100]}
                        ]
                    }
                },
                "ao": 0,
                "shapes": [
                    {
                        "ty": "gr",
                        "it": [
                            {
                                "ty": "sr",
                                "sy": 2,
                                "d": 1,
                                "pt": {"a": 0, "k": 6 if shape_type == "pulse_hub" else (4 if shape_type == "lab_grid" else 8)},
                                "p": {"a": 0, "k": [0, 0]},
                                "r": {"a": 0, "k": 0},
                                "or": {"a": 0, "k": 85},
                                "os": {"a": 0, "k": 20},
                                "nm": "PolyStar"
                            },
                            {
                                "ty": "st",
                                "c": {"a": 0, "k": [r2, g2, b2, 1]},
                                "o": {"a": 0, "k": 100},
                                "w": {"a": 0, "k": 8},
                                "lc": 2,
                                "lj": 2
                            },
                            {
                                "ty": "fl",
                                "c": {"a": 0, "k": [r1, g1, b1, 1]},
                                "o": {"a": 0, "k": 90}
                            },
                            {
                                "ty": "tr",
                                "p": {"a": 0, "k": [0, 0]},
                                "a": {"a": 0, "k": [0, 0]},
                                "s": {"a": 0, "k": [100, 100]},
                                "r": {"a": 0, "k": 0},
                                "o": {"a": 0, "k": 100}
                            }
                        ],
                        "nm": "InnerHex"
                    }
                ],
                "ip": 0,
                "op": 120,
                "st": 0
            },
            {
                "ddd": 0,
                "ind": 2,
                "ty": 4,
                "nm": "PulseRing",
                "sr": 1,
                "ks": {
                    "o": {
                        "a": 1,
                        "k": [
                            {"t": 0, "s": [85], "e": [0]},
                            {"t": 120, "s": [0]}
                        ]
                    },
                    "r": {"a": 0, "k": 0},
                    "p": {"a": 0, "k": [200, 200, 0]},
                    "a": {"a": 0, "k": [0, 0, 0]},
                    "s": {
                        "a": 1,
                        "k": [
                            {"t": 0, "s": [75, 75, 100], "e": [165, 165, 100]},
                            {"t": 120, "s": [165, 165, 100]}
                        ]
                    }
                },
                "ao": 0,
                "shapes": [
                    {
                        "ty": "gr",
                        "it": [
                            {"d": 1, "ty": "el", "s": {"a": 0, "k": [180, 180]}, "p": {"a": 0, "k": [0, 0]}},
                            {"ty": "st", "c": {"a": 0, "k": [r2, g2, b2, 1]}, "o": {"a": 0, "k": 100}, "w": {"a": 0, "k": 4}},
                            {"ty": "tr", "p": {"a": 0, "k": [0, 0]}, "a": {"a": 0, "k": [0, 0]}, "s": {"a": 0, "k": [100, 100]}, "r": {"a": 0, "k": 0}, "o": {"a": 0, "k": 100}}
                        ]
                    }
                ],
                "ip": 0,
                "op": 120,
                "st": 0
            }
        ]
    }, indent=2)


# ==============================================================================
# 2. PROJECT FILES MAP
# ==============================================================================

FILES = {}

FILES["pubspec.yaml"] = """name: aptech_it_support
description: "Aptech IT Support & Digital Twin Lab Management System"
publish_to: 'none'
version: 2.0.0+2

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core:
  firebase_auth:
  cloud_firestore:
  provider:
  intl:
  sizer:
  uuid:
  excel:
  path_provider:
  permission_handler:
  shared_preferences: ^2.3.2
  lottie: ^3.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: "^0.14.4"
  flutter_lints: ^5.0.0

flutter_launcher_icons:
  android: "launcher_icon"
  ios: false
  image_path: "assets/logo.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/logo.png"
    background_color: "#0F172A"
    theme_color: "#0EA5E9"
  windows:
    generate: true
    image_path: "assets/logo.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/logo.png"

flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/lottie/
"""

FILES["lib/main.dart"] = """import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/app_data_provider.dart';
import 'providers/filter_complaint_provider.dart';
import 'providers/lab_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()..initializeCache()),
        ChangeNotifierProvider(create: (_) => FilterComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => LabProvider()..fetchLabs()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aptech IT Support Hub',
            theme: AppTheme.lightTheme,
            initialRoute: Routes.splash,
            routes: routes,
          );
        },
      ),
    );
  }
}
"""

FILES["lib/theme/app_theme.dart"] = """import 'package:flutter/material.dart';

class AppTheme {
  // Modern Enterprise Slate & Indigo-Cyan Palette
  static const Color primaryColor = Color(0xFF0F172A);    // Slate 900
  static const Color primaryLight = Color(0xFF1E293B);    // Slate 800
  static const Color accentColor = Color(0xFF0EA5E9);     // Sky 500
  static const Color accentGlow = Color(0xFF38BDF8);      // Sky 400
  static const Color secondaryColor = Color(0xFF6366F1);  // Indigo 500

  // Semantic Status Colors
  static const Color successColor = Color(0xFF10B981);    // Emerald 500
  static const Color errorColor = Color(0xFFEF4444);      // Rose 500
  static const Color warningColor = Color(0xFFF59E0B);    // Amber 500
  static const Color infoColor = Color(0xFF3B82F6);       // Blue 500

  // Clean Surface Colors
  static const Color backgroundColor = Color(0xFFF1F5F9); // Slate 100
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8FAFC);    // Slate 50
  static const Color borderColor = Color(0xFFE2E8F0);     // Slate 200

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color statusPending = Color(0xFFEF4444);
  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusWaiting = Color(0xFF14B8A6);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: secondaryColor,
      error: errorColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
      surfaceContainerHighest: surfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: accentColor.withOpacity(0.15),
      secondarySelectedColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: accentColor,
      ),
      side: const BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'resolved':
        return statusResolved;
      case 'in progress':
      case 'inprogress':
        return statusInProgress;
      case 'pending':
        return statusPending;
      case 'waiting approval':
        return statusWaiting;
      default:
        return textSecondary;
    }
  }
}
"""

FILES["lib/routes/app_routes.dart"] = """import 'package:flutter/material.dart';
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

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgot = '/forgot';
  static const String dashboard = '/dashboard';
  static const String chats = '/chats';
  static const String filterComplaints = '/filter_complaints';
  static const String complaintDetail = '/complaint_detail';
  static const String adminAddUser = '/admin_add_user';
  static const String manageUsers = '/manage_users';
  static const String labList = '/lab_list';
  static const String notifications = '/notifications';
}

final Map<String, Widget Function(BuildContext)> routes = {
  Routes.splash: (_) => const SplashScreen(),
  Routes.onboarding: (_) => const OnboardingScreen(),
  Routes.login: (_) => const LoginScreen(),
  Routes.forgot: (_) => const ForgotPasswordScreen(),
  Routes.dashboard: (_) => const DashboardScreen(),
  Routes.chats: (_) => const ChatScreen(),
  Routes.filterComplaints: (_) => const FilterComplaintsScreen(),
  Routes.adminAddUser: (_) => const AdminAddUserScreen(),
  Routes.manageUsers: (_) => const ManageUsersScreen(),
  Routes.labList: (_) => const LabListScreen(),
  Routes.notifications: (_) => const NotificationPanelScreen(),
};
"""

FILES["lib/widgets/expressive_logo.dart"] = """import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Expressive animated vector logo for Aptech IT Hub
class ExpressiveAppLogo extends StatefulWidget {
  final double size;
  final bool showBadgeText;

  const ExpressiveAppLogo({
    super.key,
    this.size = 64,
    this.showBadgeText = false,
  });

  @override
  State<ExpressiveAppLogo> createState() => _ExpressiveAppLogoState();
}

class _ExpressiveAppLogoState extends State<ExpressiveAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.35),
                    blurRadius: widget.size * 0.35,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _ctrl.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size * 0.78, widget.size * 0.78),
                      painter: _HexNodePainter(),
                    ),
                  ),
                  Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: widget.size * 0.46,
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.showBadgeText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "APTECH NEXUS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "IT Support & Lab Twin",
                style: TextStyle(
                  color: AppTheme.accentGlow.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HexNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

FILES["lib/providers/app_data_provider.dart"] = """import 'dart:async';
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

  /// Map of complaintId -> Map<String, dynamic> (sorted newest or oldest as needed)
  final Map<String, Map<String, dynamic>> _complaintsMap = {};
  Map<String, dynamic>? _currentUserProfile;

  StreamSubscription<QuerySnapshot>? _deltaSubscription;
  StreamSubscription<QuerySnapshot>? _usersSummarySubscription;

  bool isInitialized = false;
  int totalUsersCount = 0;
  int waitingApprovalCount = 0;

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

  /// 2. Attach single shared Firestore listener using DocumentChanges delta updates
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

    // Enable Firestore persistence + listen only to docChanges
    _deltaSubscription = _db
        .collection('complaints')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: false)
        .listen((snapshot) async {
      bool changed = false;
      for (final change in snapshot.docChanges) {
        final docId = change.doc.id;
        if (change.type == DocumentChangeType.removed) {
          _complaintsMap.remove(docId);
          changed = true;
        } else {
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
  }
}
"""

FILES["lib/providers/lab_provider.dart"] = """import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lab_model.dart';
import '../models/pc_status_model.dart';

class LabProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LabModel> labs = [];
  Map<String, List<String>> _cachedTechMap = {};
  bool _listening = false;

  /// Fetch labs once per session and cache technician mapping to avoid N+1 reads
  void fetchLabs() {
    if (_listening) return;
    _listening = true;

    // Listen to technicians changes separately and cache in memory
    _db
        .collection('users')
        .where('role', isEqualTo: 'IT Technician')
        .snapshots()
        .listen((techSnap) {
      _cachedTechMap = {
        for (var doc in techSnap.docs)
          (doc.data()['name'] ?? 'Unknown').toString():
              List<String>.from(doc.data()['associatedLabs'] ?? [])
      };
      _recomputeLabAssignments();
    });

    _db.collection('labs').snapshots().listen((s) {
      labs = s.docs.map((d) => LabModel.fromMap(d.id, d.data())).toList();
      _recomputeLabAssignments();
    });
  }

  void _recomputeLabAssignments() {
    labs = labs.map((lab) {
      final labNameNormalized = lab.name.trim().toLowerCase();
      for (final entry in _cachedTechMap.entries) {
        final assignedLabsNormalized =
            entry.value.map((e) => e.toString().trim().toLowerCase());
        if (assignedLabsNormalized.contains(labNameNormalized)) {
          return lab.copyWith(assignedTo: entry.key);
        }
      }
      return lab.copyWith(assignedTo: 'Unassigned');
    }).toList();
    notifyListeners();
  }

  Future<void> addLab(LabModel lab) async {
    if (labs.any((l) => l.name.toLowerCase() == lab.name.toLowerCase())) {
      throw Exception('Lab already exists');
    }

    final assignedTechnician = _findTechnicianFromCache(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    final labRef = _db.collection('labs').doc(lab.id);
    await labRef.set(labWithTech.toMap());

    final batch = _db.batch();
    batch.set(labRef.collection('pcs').doc('IP'), PcStatusModel(pcId: 'IP').toMap());
    for (int r = 0; r < lab.rows; r++) {
      for (int c = 0; c < lab.columns; c++) {
        final id = 'PC-${r + 1}-${c + 1}';
        batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
      }
    }
    await batch.commit();
  }

  Future<void> updateLabAndSyncPcs(LabModel lab) async {
    final labRef = _db.collection('labs').doc(lab.id);
    final assignedTechnician = _findTechnicianFromCache(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    await labRef.update(labWithTech.toMap());

    final existing = await labRef.collection('pcs').get();
    final existingIds = existing.docs.map((d) => d.id).toSet();

    final batch = _db.batch();
    for (int r = 0; r < lab.rows; r++) {
      for (int c = 0; c < lab.columns; c++) {
        final id = 'PC-${r + 1}-${c + 1}';
        if (!existingIds.contains(id)) {
          batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
        }
        existingIds.remove(id);
      }
    }

    existingIds.remove('IP');
    for (final id in existingIds) {
      batch.delete(labRef.collection('pcs').doc(id));
    }

    await batch.commit();
  }

  Future<void> deleteLab(String id) async {
    final labRef = _db.collection('labs').doc(id);
    final pcs = await labRef.collection('pcs').get();

    final batch = _db.batch();
    for (final p in pcs.docs) {
      batch.delete(p.reference);
    }
    batch.delete(labRef);
    await batch.commit();
  }

  Future<void> updatePcStatus(String labId, String pcId, PcStatusModel s) async {
    await _db
        .collection('labs')
        .doc(labId)
        .collection('pcs')
        .doc(pcId)
        .set(s.toMap(), SetOptions(merge: true));
  }

  Stream<Map<String, PcStatusModel>> streamLabPcStatuses(String labId) {
    return _db.collection('labs').doc(labId).collection('pcs').snapshots().map(
          (s) => {for (final d in s.docs) d.id: PcStatusModel.fromMap(d.id, d.data())},
        );
  }

  String _findTechnicianFromCache(String labName) {
    final norm = labName.trim().toLowerCase();
    for (final entry in _cachedTechMap.entries) {
      if (entry.value.map((e) => e.trim().toLowerCase()).contains(norm)) {
        return entry.key;
      }
    }
    return 'Unassigned';
  }
}
"""

FILES["lib/screens/splash_screen.dart"] = """import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../widgets/animations/network_background.dart';
import '../widgets/expressive_logo.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding_v2') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    });
  }

  @override
  void dispose() {
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
                    const ExpressiveAppLogo(size: 110),
                    SizedBox(height: 3.5.h),
                    const Text(
                      "APTECH IT NEXUS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Smart Support • Digital Lab Twin • Zero-Lag Sync",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
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
"""

FILES["lib/screens/onboarding/onboarding_screen.dart"] = """import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/expressive_logo.dart';
import '../../widgets/animations/network_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      badge: "AI-ASSISTED ROUTING",
      title: "Auto-Detected Lab & Issue Dispatch",
      description:
          "Simply type a message like 'Lab 104 PC mouse not working'. The system automatically detects the lab, classifies the hardware/software issue, and alerts the assigned IT technician.",
      lottieAsset: "assets/lottie/it_hub_lottie.json",
      fallbackIcon: Icons.bolt_rounded,
    ),
    _OnboardingSlide(
      badge: "DIGITAL TWIN LABS",
      title: "Interactive 3D Lab Workstation Matrix",
      description:
          "Inspect every workstation's CPU, monitor, keyboard, cables, RAM, and SSD status in real time. Filter healthy vs faulty PCs with a single tap.",
      lottieAsset: "assets/lottie/lab_twin_lottie.json",
      fallbackIcon: Icons.grid_view_rounded,
    ),
    _OnboardingSlide(
      badge: "LOCAL CACHE ENGINE",
      title: "Instant Offline-First Group Chat",
      description:
          "Messages and ticket statuses are cached locally on your device for zero-lag loading and minimal cloud reads. Approved accounts can log in immediately.",
      lottieAsset: "assets/lottie/instant_chat_lottie.json",
      fallbackIcon: Icons.forum_rounded,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding_v2', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          const AnimatedNetworkBackground(
            color: AppTheme.accentColor,
            backgroundColor: AppTheme.primaryColor,
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsivePadding(context),
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ExpressiveAppLogo(size: 44, showBadgeText: true),
                          TextButton(
                            onPressed: _completeOnboarding,
                            child: const Text(
                              "Skip",
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (idx) => setState(() => _currentIndex = idx),
                          itemBuilder: (context, idx) {
                            final item = _slides[idx];
                            return SingleChildScrollView(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withOpacity(0.78),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 210,
                                      width: 210,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Lottie.asset(
                                            item.lottieAsset,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const SizedBox(),
                                          ),
                                          Icon(
                                            item.fallbackIcon,
                                            size: 54,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.accentGlow.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        item.badge,
                                        style: const TextStyle(
                                          color: AppTheme.accentGlow,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      item.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      item.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.78),
                                        fontSize: 15,
                                        height: 1.55,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom Controls + ChoiceChip-like step indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(_slides.length, (i) {
                              final active = i == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(right: 8),
                                width: active ? 28 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.accentGlow
                                      : Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_currentIndex < _slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                );
                              } else {
                                _completeOnboarding();
                              }
                            },
                            icon: Icon(
                              _currentIndex == _slides.length - 1
                                  ? Icons.login_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                            label: Text(
                              _currentIndex == _slides.length - 1
                                  ? "Proceed to Login"
                                  : "Next",
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
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String badge;
  final String title;
  final String description;
  final String lottieAsset;
  final IconData fallbackIcon;

  const _OnboardingSlide({
    required this.badge,
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.fallbackIcon,
  });
}
"""

FILES["lib/widgets/interactive_tour_overlay.dart"] = """import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon = Icons.touch_app_rounded,
  });
}

/// Game-style Interactive Coach Mark Spotlight Tutorial
class InteractiveTourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;

  const InteractiveTourOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<InteractiveTourOverlay> createState() => _InteractiveTourOverlayState();
}

class _InteractiveTourOverlayState extends State<InteractiveTourOverlay> {
  int _index = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
  }

  Future<void> _locateTarget() async {
    if (!mounted || _index >= widget.steps.length) return;
    final key = widget.steps[_index].targetKey;
    final ctx = key.currentContext;

    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
      if (!mounted) return;
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _targetRect = offset & renderBox.size;
        });
        return;
      }
    }
    setState(() => _targetRect = null);
  }

  void _next() {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final screenSize = MediaQuery.of(context).size;
    final rect = _targetRect;

    // Position the tooltip card either below or above the spotlighted widget
    double cardTop = screenSize.height * 0.35;
    if (rect != null) {
      if (rect.bottom + 220 < screenSize.height) {
        cardTop = rect.bottom + 18;
      } else {
        cardTop = (rect.top - 210).clamp(24.0, screenSize.height - 240);
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dimmed background with cutout spotlight
          GestureDetector(
            onTap: _next,
            child: CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(targetRect: rect),
            ),
          ),

          // Pulsing border ring around target
          if (rect != null)
            Positioned(
              left: rect.left - 6,
              top: rect.top - 6,
              width: rect.width + 12,
              height: rect.height + 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentGlow, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGlow.withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Game-style Coach Dialog Card
          Positioned(
            top: cardTop,
            left: 20,
            right: 20,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGlow, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              step.icon,
                              color: AppTheme.accentGlow,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "GUIDE • STEP ${_index + 1} OF ${widget.steps.length}",
                              style: const TextStyle(
                                color: AppTheme.accentGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onComplete,
                            child: const Text(
                              "Skip Tour",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_index > 0)
                            TextButton(
                              onPressed: () {
                                setState(() => _index--);
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _locateTarget(),
                                );
                              },
                              child: const Text(
                                "Previous",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _next,
                            icon: Icon(
                              _index == widget.steps.length - 1
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _index == widget.steps.length - 1
                                  ? "Finish Guide"
                                  : "Got It, Next",
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
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  _SpotlightPainter({this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.76);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      final padded = targetRect!.inflate(6);
      final holePath = Path()
        ..addRRect(RRect.fromRectAndRadius(padded, const Radius.circular(14)));
      final combined = Path.combine(PathOperation.difference, fullPath, holePath);
      canvas.drawPath(combined, bgPaint);
    } else {
      canvas.drawPath(fullPath, bgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}
"""

FILES["lib/screens/auth/login_screen.dart"] = """import 'package:flutter/material.dart';
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
                                          Icons.auto_Fix_high,
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
"""

FILES["lib/screens/dashboard/dashboard_screen.dart"] = """import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_data_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../services/export_excel_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/expressive_logo.dart';
import '../../widgets/interactive_tour_overlay.dart';
import 'complaint_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription? _notifSub;
  final DateTime _screenOpenTime = DateTime.now();

  // Filter Chips state (Replaces old Dropdowns & TabBars)
  String _selectedStatusChip = "All";
  String _selectedLabChip = "All Labs";
  String _selectedCategoryChip = "All";

  // Interactive Game-Style Tutorial Coach Keys
  final GlobalKey _welcomeKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _filterChipsKey = GlobalKey();
  final GlobalKey _quickActionsKey = GlobalKey();
  final GlobalKey _chatFabKey = GlobalKey();

  bool _showTour = false;

  @override
  void initState() {
    super.initState();
    _initNotificationListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstTimeTour());
  }

  Future<void> _checkFirstTimeTour() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final dataProv = context.read<AppDataProvider>();
    if (dataProv.currentUserProfile == null) {
      await dataProv.bindSessionStreams(user.uid);
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'tour_completed_${user.uid}';
    final seen = prefs.getBool(key) ?? false;
    if (!seen && mounted) {
      setState(() => _showTour = true);
    }
  }

  Future<void> _completeTour() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tour_completed_${user.uid}', true);
    }
    if (mounted) {
      setState(() => _showTour = false);
    }
  }

  void _initNotificationListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    NotificationService().requestPermission();

    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() ?? {};
          final title = (data['title'] ?? 'Notification').toString();
          final message = (data['message'] ?? '').toString();
          final complaintId = (data['complaintId'] ?? '').toString();
          final createdAt = data['createdAt'] as Timestamp?;

          if (createdAt != null &&
              createdAt.toDate().isAfter(
                _screenOpenTime.subtract(const Duration(seconds: 5)),
              )) {
            NotificationService().showPushNotification(title, message);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title: $message"),
                  action: SnackBarAction(
                    label: "VIEW",
                    textColor: AppTheme.accentGlow,
                    onPressed: () {
                      if (complaintId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ComplaintDetailScreen(complaintId: complaintId),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, Routes.notifications);
                      }
                    },
                  ),
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      context.read<AppDataProvider>().disposeStreams();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  Future<void> _exportAllComplaintsToExcel() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text("Generating Excel report...")),
    );
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .get();
      if (snapshot.docs.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text("No complaints found to export.")),
        );
        return;
      }
      await ExportExcelService.exportToExcel(snapshot.docs);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Excel report downloaded (.xlsx)"),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Export failed: $e"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final isAdmin = appData.isAdmin;
    final isSuperAdmin = appData.isSuperAdmin;
    final role = appData.userRole;
    final userName = appData.userName;

    // Filter complaints locally from cached memory (Zero extra Firebase reads!)
    final allComplaints = appData.complaintsNewestFirst;
    final roleScopedComplaints = isAdmin
        ? allComplaints
        : role.toLowerCase() == 'faculty'
            ? allComplaints
                .where((c) => (c['facultyName'] ?? '') == userName)
                .toList()
            : allComplaints;

    final pendingCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'Pending')
        .length;
    final progressCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'In Progress')
        .length;
    final resolvedCount = roleScopedComplaints
        .where((c) => (c['status'] ?? '') == 'Resolved')
        .length;

    final filteredComplaints = roleScopedComplaints.where((c) {
      final st = (c['status'] ?? 'Pending').toString();
      final lab = (c['lab'] ?? 'Unknown Lab').toString();
      final cat = (c['issueCategory'] ?? 'Other').toString();

      final statusOk = _selectedStatusChip == 'All' ||
          st.toLowerCase() == _selectedStatusChip.toLowerCase();
      final labOk = _selectedLabChip == 'All Labs' || lab == _selectedLabChip;
      final catOk = _selectedCategoryChip == 'All' ||
          cat.toLowerCase() == _selectedCategoryChip.toLowerCase();

      return statusOk && labOk && catOk;
    }).toList();

    final availableLabs = <String>{
      'All Labs',
      ...appData.associatedLabs,
      ...roleScopedComplaints
          .map((c) => (c['lab'] ?? '').toString())
          .where((s) => s.isNotEmpty),
    }.toList();

    final tourSteps = <TourStep>[
      TourStep(
        targetKey: _welcomeKey,
        title: "Welcome to Your Command Center",
        description:
            "This header shows your active role, approval badge, and quick status summary.",
        icon: Icons.verified_user_rounded,
      ),
      TourStep(
        targetKey: _statsKey,
        title: "Real-Time Telemetry Counters",
        description:
            "Live ticket counts update automatically using our local delta-sync cache without re-fetching unchanged documents.",
        icon: Icons.analytics_outlined,
      ),
      TourStep(
        targetKey: _quickActionsKey,
        title: "Digital Twin Labs & Management",
        description:
            "Jump into interactive 3D Lab Workstation maps, manage users, or export Excel reports from here.",
        icon: Icons.computer_rounded,
      ),
      TourStep(
        targetKey: _filterChipsKey,
        title: "Instant Chip Filtering",
        description:
            "All old tab bars and dropdowns are replaced with one-tap Filter Chips. Filter by Status, Lab, or Category in 0ms.",
        icon: Icons.tune_rounded,
      ),
      TourStep(
        targetKey: _chatFabKey,
        title: "Live IT Support Group Chat",
        description:
            "Tap here anytime to report an issue or update ticket statuses in the offline-cached IT Hub Chat.",
        icon: Icons.forum_rounded,
      ),
    ];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const ExpressiveAppLogo(size: 34),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    isSuperAdmin
                        ? "Super Admin Console"
                        : isAdmin
                            ? "Admin Workspace"
                            : "IT Support Hub",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: "Interactive Guide Tour",
                icon: const Icon(Icons.help_outline_rounded),
                onPressed: () => setState(() => _showTour = true),
              ),
              StreamBuilder<int>(
                stream: NotificationService().getUnreadCountStream(
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return IconButton(
                    tooltip: "Notifications",
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppTheme.errorColor,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.notifications),
                  );
                },
              ),
              IconButton(
                tooltip: "Sign Out",
                icon: const Icon(Icons.logout_rounded),
                onPressed: _logout,
              ),
            ],
          ),
          body: ResponsiveWrapper(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: ResponsiveUtils.getResponsivePadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome Banner
                  Container(
                    key: _welcomeKey,
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ACTIVE SESSION • LOCAL DELTA-CACHE ENABLED",
                              style: TextStyle(
                                color: AppTheme.accentGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userName.isEmpty ? "Welcome Back" : userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSuperAdmin
                                ? Colors.amber.withOpacity(0.18)
                                : AppTheme.accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSuperAdmin
                                  ? Colors.amber
                                  : AppTheme.accentGlow,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuperAdmin
                                    ? Icons.shield_rounded
                                    : Icons.verified_user_rounded,
                                size: 16,
                                color: isSuperAdmin
                                    ? Colors.amberAccent
                                    : AppTheme.accentGlow,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSuperAdmin
                                    ? "Super Admin"
                                    : (role.isEmpty ? "Approved User" : role),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Responsive Telemetry Stat Grid
                  Container(
                    key: _statsKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final cards = <Widget>[
                          if (isAdmin) ...[
                            _buildMetricTile(
                              "Total Users",
                              appData.totalUsersCount,
                              AppTheme.infoColor,
                              Icons.people_alt_rounded,
                            ),
                            _buildMetricTile(
                              "Pending Approval",
                              appData.waitingApprovalCount,
                              Colors.teal,
                              Icons.hourglass_top_rounded,
                            ),
                          ],
                          _buildMetricTile(
                            "Pending Tickets",
                            pendingCount,
                            AppTheme.errorColor,
                            Icons.error_outline_rounded,
                          ),
                          _buildMetricTile(
                            "In Progress",
                            progressCount,
                            AppTheme.warningColor,
                            Icons.autorenew_rounded,
                          ),
                          _buildMetricTile(
                            "Resolved",
                            resolvedCount,
                            AppTheme.successColor,
                            Icons.task_alt_rounded,
                          ),
                        ];

                        final cols = isWide ? cards.length : 2;
                        final spacing = 12.0;
                        final width =
                            (constraints.maxWidth - (spacing * (cols - 1))) /
                                cols;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: cards
                              .map((c) => SizedBox(width: width, child: c))
                              .toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Quick Navigation Modules (Labs, Users, Analytics)
                  Container(
                    key: _quickActionsKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Workspace Modules",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth > 800
                                ? 3
                                : constraints.maxWidth > 520
                                    ? 2
                                    : 1;
                            final spacing = 12.0;
                            final itemW =
                                (constraints.maxWidth - (spacing * (cols - 1))) /
                                    cols;

                            final actions = <Widget>[
                              if (isAdmin ||
                                  role.toLowerCase() == 'it technician')
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Digital Twin Labs",
                                    subtitle:
                                        "Interactive 3D PC matrix & hardware health",
                                    icon: Icons.developer_board_rounded,
                                    color: AppTheme.accentColor,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.labList,
                                    ),
                                  ),
                                ),
                              if (isAdmin)
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Manage Users",
                                    subtitle:
                                        "Chip-filtered Faculty, Techs & approvals",
                                    icon: Icons.manage_accounts_rounded,
                                    color: AppTheme.secondaryColor,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.manageUsers,
                                    ),
                                  ),
                                ),
                              if (isAdmin)
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Advanced Analytics",
                                    subtitle:
                                        "Multi-layer chip filters & Excel export",
                                    icon: Icons.insights_rounded,
                                    color: Colors.teal,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.filterComplaints,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: itemW,
                                child: _buildModuleCard(
                                  title: "IT Support Group Chat",
                                  subtitle:
                                      "Offline-cached live ticket dispatch room",
                                  icon: Icons.forum_rounded,
                                  color: AppTheme.successColor,
                                  onTap: () =>
                                      Navigator.pushNamed(context, Routes.chats),
                                ),
                              ),
                              if (kIsWeb && isAdmin)
                                SizedBox(
                                  width: itemW,
                                  child: _buildModuleCard(
                                    title: "Export Full Log (.xlsx)",
                                    subtitle:
                                        "Download complete complaint spreadsheet",
                                    icon: Icons.download_for_offline_rounded,
                                    color: Colors.amber.shade800,
                                    onTap: _exportAllComplaintsToExcel,
                                  ),
                                ),
                            ];

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: actions,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 4. Chip-Based Ticket Feed (Replaces old Dropdowns)
                  Container(
                    key: _filterChipsKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Live Support Tickets",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              "${filteredComplaints.length} showing",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              "All",
                              "Pending",
                              "In Progress",
                              "Resolved"
                            ].map((st) {
                              final selected = _selectedStatusChip == st;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(st),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setState(() => _selectedStatusChip = st),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Category Filter Chips
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              "All",
                              "Hardware",
                              "Software",
                              "Network",
                              "Exam",
                              "Access",
                              "Other"
                            ].map((cat) {
                              final selected = _selectedCategoryChip == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    cat == "All" ? "All Categories" : cat,
                                  ),
                                  selected: selected,
                                  onSelected: (_) => setState(
                                    () => _selectedCategoryChip = cat,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Lab Filter Chips (if multiple labs available)
                        if (availableLabs.length > 1) ...[
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: availableLabs.map((lab) {
                                final selected = _selectedLabChip == lab;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    avatar: Icon(
                                      Icons.computer,
                                      size: 15,
                                      color: selected
                                          ? AppTheme.accentColor
                                          : AppTheme.textSecondary,
                                    ),
                                    label: Text(lab),
                                    selected: selected,
                                    onSelected: (_) =>
                                        setState(() => _selectedLabChip = lab),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Filtered Tickets List
                  if (filteredComplaints.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No matching tickets for the selected chip filters",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredComplaints.map((c) => _buildTicketCard(c)),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: _chatFabKey,
            onPressed: () => Navigator.pushNamed(context, Routes.chats),
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text("IT Hub Chat"),
          ),
        ),

        // Interactive Game-Style Coach Mark Overlay
        if (_showTour)
          InteractiveTourOverlay(
            steps: tourSteps,
            onComplete: _completeTour,
          ),
      ],
    );
  }

  Widget _buildMetricTile(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> data) {
    final status = (data['status'] ?? 'Pending').toString();
    final complaintId = (data['complaintId'] ?? '').toString();
    final statusColor = AppTheme.getStatusColor(status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: complaintId.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComplaintDetailScreen(complaintId: complaintId),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (data['issueCategory'] ?? 'General').toString(),
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (data['issue'] ?? 'Support Ticket').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                (data['message'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _metaBadge(
                    Icons.computer_rounded,
                    (data['lab'] ?? 'Unknown Lab').toString(),
                  ),
                  _metaBadge(
                    Icons.person_outline_rounded,
                    "By: ${data['facultyName'] ?? 'Faculty'}",
                  ),
                  _metaBadge(
                    Icons.engineering_outlined,
                    "Tech: ${data['assignedToName'] ?? 'Unassigned'}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
"""

FILES["lib/screens/admin/manage_users_screen.dart"] = """import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'user_dialogs.dart';

/// Completely TabBar-free Manage Users Screen!
/// Uses interactive ChoiceChips & FilterChips for Role, Approval Status, and Search.
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedRoleChip = "All Roles";
  String _selectedApprovalChip = "All";
  String _searchQuery = "";
  final TextEditingController _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final appData = context.watch<AppDataProvider>();
    final isSuperAdmin = appData.isSuperAdmin;

    final roleChips = <String>[
      "All Roles",
      "Faculty",
      "IT Technician",
      if (isSuperAdmin) "Admin",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isSuperAdmin ? "Manage Users & Admins" : "Manage Users"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(isSuperAdmin ? "Add User / Admin" : "Add User"),
        onPressed: () => Navigator.pushNamed(context, '/admin_add_user'),
      ),
      body: ResponsiveWrapper(
        child: StreamBuilder<QuerySnapshot>(
          stream: authProv.usersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exclude Super Admin accounts from general list
            final allDocs = snapshot.data!.docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final docRole = (data['role'] ?? '').toString().toLowerCase().trim();
              final docEmail = (data['email'] ?? '').toString().toLowerCase().trim();
              final isDocSA = data['isSuperAdmin'] == true;
              if (docEmail == 'wahajaamir2@gmail.com' ||
                  docEmail == 'cah-sf@aptech-education.com.pk' ||
                  docRole == 'super admin' ||
                  docRole == 'superadmin' ||
                  isDocSA) {
                return false;
              }
              if (!isSuperAdmin && docRole == 'admin') {
                return false;
              }
              return true;
            }).toList();

            // Apply Chip Filters & Search
            final filteredDocs = allDocs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final role = (data['role'] ?? '').toString().trim();
              final isApproved = data['isApproved'] == true;
              final name = (data['name'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();

              final roleMatch = _selectedRoleChip == "All Roles" || role == _selectedRoleChip;
              final approvalMatch = _selectedApprovalChip == "All" ||
                  (_selectedApprovalChip == "Approved" && isApproved) ||
                  (_selectedApprovalChip == "Pending" && !isApproved);
              final searchMatch = _searchQuery.isEmpty ||
                  name.contains(_searchQuery.toLowerCase()) ||
                  email.contains(_searchQuery.toLowerCase());

              return roleMatch && approvalMatch && searchMatch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Search & Filter Chips Card (No TabBar!)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchC,
                        onChanged: (v) => setState(() => _searchQuery = v.trim()),
                        decoration: InputDecoration(
                          hintText: "Search by name or email...",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchC.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: roleChips.map((r) {
                            final selected = _selectedRoleChip == r;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(
                                  r == "Faculty"
                                      ? Icons.school_outlined
                                      : r == "IT Technician"
                                          ? Icons.engineering_outlined
                                          : r == "Admin"
                                              ? Icons.admin_panel_settings_outlined
                                              : Icons.groups_outlined,
                                  size: 16,
                                  color: selected
                                      ? AppTheme.accentColor
                                      : AppTheme.textSecondary,
                                ),
                                label: Text(r),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _selectedRoleChip = r),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["All", "Approved", "Pending"].map((st) {
                            final selected = _selectedApprovalChip == st;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text("Status: $st"),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _selectedApprovalChip = st),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredDocs.isEmpty
                      ? const Center(
                          child: Text(
                            "No users match the selected filter chips",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, idx) {
                            final d = filteredDocs[idx];
                            final data = d.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? 'User').toString();
                            final email = (data['email'] ?? '').toString();
                            final role = (data['role'] ?? 'Faculty').toString();
                            final isApproved = data['isApproved'] == true;
                            final labs =
                                List<String>.from(data['associatedLabs'] ?? []);

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              AppTheme.accentColor.withOpacity(0.15),
                                          radius: 22,
                                          child: Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: AppTheme.accentColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                "$email • $role",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isApproved
                                                    ? AppTheme.successColor
                                                    : AppTheme.warningColor)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isApproved
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                            ),
                                          ),
                                          child: Text(
                                            isApproved ? "Approved" : "Pending",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isApproved
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (labs.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: labs
                                            .map(
                                              (l) => Chip(
                                                label: Text(l),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const Divider(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18,
                                          ),
                                          label: const Text("Details"),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => UserDetailDialog(
                                              docId: d.id,
                                              data: data,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          label: const Text("Edit"),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => EditUserDialog(
                                              docId: d.id,
                                              initial: data,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: Icon(
                                            isApproved
                                                ? Icons.block_rounded
                                                : Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          label: Text(
                                            isApproved ? "Revoke" : "Approve",
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: isApproved
                                                ? AppTheme.warningColor
                                                : AppTheme.successColor,
                                          ),
                                          onPressed: () => authProv
                                              .adminSetApproval(d.id, !isApproved),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                          ),
                                          label: const Text("Delete"),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppTheme.errorColor,
                                          ),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Delete User"),
                                                content: Text(
                                                  "Remove '$name' permanently?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppTheme.errorColor,
                                                    ),
                                                    onPressed: () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await authProv.adminDeleteUserFully(
                                                uid: d.id,
                                                email: email,
                                                tempPassword: data['tempPassword'],
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
"""

FILES["lib/screens/chats/chats_screen.dart"] = """import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../services/complains_servcie.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

/// Offline-Cached & Chip-Filtered IT Hub Group Chat.
/// Reads directly from AppDataProvider's local cache + single delta listener
/// so opening or chatting NEVER re-fetches the whole Firestore collection!
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageC = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ComplaintService complaintService = ComplaintService();

  String _selectedStatusFilter = "All";

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(AppDataProvider appData) async {
    final text = messageC.text.trim();
    if (text.isEmpty) return;
    messageC.clear();

    await complaintService.createComplaint(message: text);
    _scrollToBottom();
  }

  Future<void> _updateStatus(
    AppDataProvider appData,
    String complaintId,
    String newStatus,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await complaintService.updateStatus(
      complaintId: complaintId,
      newStatus: newStatus,
      updaterId: uid,
      updaterName: appData.userName,
      resolverId: newStatus.toLowerCase() == 'resolved' ? uid : null,
      resolverName:
          newStatus.toLowerCase() == 'resolved' ? appData.userName : null,
    );
  }

  String _formatTime(dynamic tsMs) {
    if (tsMs == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(
      tsMs is int ? tsMs : DateTime.now().millisecondsSinceEpoch,
    );
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final canUpdateStatus =
        appData.userRole.toLowerCase() == 'it technician' || appData.isAdmin;

    final allMessages = appData.complaintsOldestFirst;
    final messages = _selectedStatusFilter == "All"
        ? allMessages
        : allMessages
            .where(
              (m) =>
                  (m['status'] ?? 'Pending').toString().toLowerCase() ==
                  _selectedStatusFilter.toLowerCase(),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IT Hub Dispatch Chat", style: TextStyle(fontSize: 17)),
            Text(
              "Local Delta-Cache Active • Auto Lab & Issue Detection",
              style: TextStyle(fontSize: 11, color: AppTheme.accentGlow),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Filter Chips Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Pending", "In Progress", "Resolved"]
                    .map((status) {
                  final selected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Cached Chat Stream
          Expanded(
            child: ResponsiveWrapper(
              child: messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No messages in this filter view",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index];
                        final isMe = data['facultyId'] == currentUid;
                        final status = (data['status'] ?? 'Pending').toString();
                        final statusColor = AppTheme.getStatusColor(status);
                        final lab = (data['lab'] ?? 'Unknown Lab').toString();
                        final category =
                            (data['issueCategory'] ?? 'Other').toString();

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: ResponsiveUtils.isDesktop(context)
                                  ? 520
                                  : MediaQuery.of(context).size.width * 0.82,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 18),
                                ),
                                border: Border.all(
                                  color: isMe
                                      ? AppTheme.primaryLight
                                      : AppTheme.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (data['facultyName'] ?? 'User')
                                              .toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: isMe
                                                ? AppTheme.accentGlow
                                                : AppTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTapDown: (details) async {
                                          if (!canUpdateStatus) return;
                                          final selected =
                                              await showMenu<String>(
                                            context: context,
                                            position: RelativeRect.fromLTRB(
                                              details.globalPosition.dx,
                                              details.globalPosition.dy,
                                              details.globalPosition.dx,
                                              details.globalPosition.dy,
                                            ),
                                            items: const [
                                              PopupMenuItem(
                                                value: 'Pending',
                                                child: Text('Mark Pending'),
                                              ),
                                              PopupMenuItem(
                                                value: 'In Progress',
                                                child: Text('Mark In Progress'),
                                              ),
                                              PopupMenuItem(
                                                value: 'Resolved',
                                                child: Text('Mark Resolved'),
                                              ),
                                            ],
                                          );
                                          if (selected != null &&
                                              data['complaintId'] != null) {
                                            _updateStatus(
                                              appData,
                                              data['complaintId'].toString(),
                                              selected,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                status,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (canUpdateStatus) ...[
                                                const SizedBox(width: 2),
                                                const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    (data['message'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      height: 1.4,
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          _miniTag(lab, isMe),
                                          _miniTag(category, isMe),
                                        ],
                                      ),
                                      Text(
                                        _formatTime(data['timestampMs']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isMe
                                              ? Colors.white60
                                              : AppTheme.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Message Composer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SafeArea(
              child: ResponsiveWrapper(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageC,
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(appData),
                        decoration: InputDecoration(
                          hintText:
                              "Describe issue & lab (e.g. 'Lab 103 PC-1-2 internet down')...",
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      onPressed: () => _sendMessage(appData),
                      child: const Icon(Icons.send_rounded),
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

  Widget _miniTag(String text, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isMe ? Colors.white12 : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isMe ? Colors.white70 : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
"""

FILES["lib/widgets/pc_tile_3d.dart"] = """import 'package:flutter/material.dart';
import '../models/pc_status_model.dart';
import '../theme/app_theme.dart';

/// Clean, Professional Isometric Digital-Twin Workstation Card
class PcTile3D extends StatelessWidget {
  final String pcId;
  final bool isActive;
  final PcStatusModel? status;
  final VoidCallback onTap;

  const PcTile3D({
    super.key,
    required this.pcId,
    required this.isActive,
    required this.onTap,
    this.status,
  });

  bool get isHealthy {
    if (status == null) return false;
    final s = status!;
    return s.keyboardOk &&
        s.mouseOk &&
        s.ledOk &&
        s.cpuWorking &&
        s.vgaCableOk &&
        s.powerCableOk &&
        s.internetCableOk;
  }

  @override
  Widget build(BuildContext context) {
    final s = status;
    final healthy = isHealthy;
    final accent = !isActive
        ? AppTheme.textTertiary
        : healthy
            ? AppTheme.successColor
            : AppTheme.errorColor;

    final isInstructor = pcId.toLowerCase().contains('instructor') || pcId == 'IP';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isInstructor ? 156 : 124,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withOpacity(0.65),
              width: healthy ? 1.5 : 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Status Pill & PC ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      pcId,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Isometric Monitor Graphic
              Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    isInstructor
                        ? Icons.cast_for_education_rounded
                        : healthy
                            ? Icons.desktop_windows_rounded
                            : Icons.report_problem_rounded,
                    color: healthy ? AppTheme.accentGlow : AppTheme.errorColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Peripheral Micro-LED Indicators (CPU, Display, Input, LAN)
              if (s != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _microDot(Icons.memory, s.cpuWorking),
                    _microDot(Icons.monitor, s.ledOk && s.vgaCableOk),
                    _microDot(Icons.mouse, s.keyboardOk && s.mouseOk),
                    _microDot(Icons.lan, s.internetCableOk),
                  ],
                ),
              if (s != null) ...[
                const SizedBox(height: 6),
                Text(
                  "${s.ram} • ${s.ssd}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _microDot(IconData icon, bool ok) {
    return Icon(
      icon,
      size: 13,
      color: ok ? AppTheme.successColor : AppTheme.errorColor,
    );
  }
}
"""

FILES["lib/screens/labs/lab_list_screen.dart"] = """import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../providers/app_data_provider.dart';
import 'add_edit_labs_screens.dart';
import 'lab_3d_screen.dart';
import '../../services/export_excel_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class LabListScreen extends StatefulWidget {
  const LabListScreen({super.key});

  @override
  State<LabListScreen> createState() => _LabListScreenState();
}

class _LabListScreenState extends State<LabListScreen> {
  String _selectedLayoutChip = "All Layouts";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabProvider>();
    final appData = context.watch<AppDataProvider>();
    final isAdmin = appData.isAdmin;
    final associatedLabs = appData.associatedLabs;

    final bool isMobileApp = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final roleLabs = isAdmin
        ? provider.labs
        : provider.labs.where((lab) {
            final labName = lab.name.trim().toLowerCase();
            return associatedLabs
                .map((e) => e.trim().toLowerCase())
                .contains(labName);
          }).toList();

    final filteredLabs = roleLabs.where((lab) {
      final layoutMatch = _selectedLayoutChip == "All Layouts" ||
          lab.layoutType.toLowerCase() == _selectedLayoutChip.toLowerCase();
      final searchMatch = _searchQuery.isEmpty ||
          lab.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lab.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase());
      return layoutMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Twin Labs'),
        actions: [
          if (isAdmin && !isMobileApp)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export All Labs (.xlsx)',
              onPressed: () async {
                if (roleLabs.isEmpty) return;
                final Map<String, List<PcStatusModel>> labPcMap = {};
                for (final lab in roleLabs) {
                  final pcsMap =
                      await provider.streamLabPcStatuses(lab.id).first;
                  labPcMap[lab.id] = pcsMap.values.toList();
                }
                await ExportExcelService.exportAllLabs(
                  labs: roleLabs,
                  labPcMap: labPcMap,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All labs exported to Excel'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_box_rounded),
              tooltip: 'Create New Lab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditLabScreen()),
                );
              },
            ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search & Chip Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: const InputDecoration(
                      hintText: "Search by Lab number or assigned technician...",
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All Layouts", "Theater", "U", "Custom"]
                          .map((layout) {
                        final selected = _selectedLayoutChip == layout;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              layout == "U" ? "U-Shape Layout" : layout,
                            ),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedLayoutChip = layout),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredLabs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.computer_outlined,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAdmin
                                ? 'No labs match your filter. Add a new lab with +'
                                : 'No labs are currently assigned to your account',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = 1;
                          if (constraints.maxWidth > 620) columns = 2;
                          if (constraints.maxWidth > 1020) columns = 3;
                          const double spacing = 16;
                          final double itemWidth =
                              (constraints.maxWidth - (spacing * (columns - 1))) /
                                  columns;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: filteredLabs.map((lab) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildModernLabCard(
                                  context,
                                  lab,
                                  isAdmin,
                                  provider,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLabCard(
    BuildContext context,
    LabModel lab,
    bool isAdmin,
    LabProvider provider,
  ) {
    final totalWorkstations = (lab.rows * lab.columns) + 1;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Lab3DViewScreen(lab: lab)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.developer_board_rounded,
                      color: AppTheme.accentGlow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.engineering_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lab.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$totalWorkstations PCs",
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _specItem(Icons.table_rows_rounded, "Rows", "${lab.rows}"),
                    _specItem(
                      Icons.view_column_rounded,
                      "Columns",
                      "${lab.columns}",
                    ),
                    _specItem(
                      Icons.dashboard_customize_rounded,
                      "Topology",
                      lab.layoutType.toUpperCase(),
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text("Configure"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditLabScreen(lab: lab),
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text("Delete"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Lab"),
                            content: Text(
                              "Delete ${lab.name} and all its workstation records?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await provider.deleteLab(lab.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _specItem(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
"""

FILES["lib/screens/labs/lab_3d_screen.dart"] = """import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/lab_model.dart';
import '../../models/pc_status_model.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/pc_tile_3d.dart';
import '../../services/export_excel_service.dart';

class Lab3DViewScreen extends StatefulWidget {
  final LabModel lab;
  const Lab3DViewScreen({super.key, required this.lab});

  @override
  State<Lab3DViewScreen> createState() => _Lab3DViewScreenState();
}

class _Lab3DViewScreenState extends State<Lab3DViewScreen> {
  String _healthFilterChip = "All PCs";

  bool _isPcHealthy(PcStatusModel s) {
    return s.keyboardOk &&
        s.mouseOk &&
        s.ledOk &&
        s.cpuWorking &&
        s.vgaCableOk &&
        s.powerCableOk &&
        s.internetCableOk;
  }

  void _openPcDialog(BuildContext context, PcStatusModel original) async {
    final provider = context.read<LabProvider>();
    final status = original.copy();

    final ramC = TextEditingController(text: status.ram);
    final ssdC = TextEditingController(text: status.ssd);
    final osC = TextEditingController(text: status.os);
    final notesC = TextEditingController(text: status.notes);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.desktop_windows_rounded, color: AppTheme.accentColor),
                const SizedBox(width: 10),
                Text("Configure ${status.pcId}"),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Toggle Component Health Chips",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggleChip(
                          "CPU Working",
                          status.cpuWorking,
                          (v) => setDialogState(() => status.cpuWorking = v),
                        ),
                        _toggleChip(
                          "LED Monitor",
                          status.ledOk,
                          (v) => setDialogState(() => status.ledOk = v),
                        ),
                        _toggleChip(
                          "Keyboard",
                          status.keyboardOk,
                          (v) => setDialogState(() => status.keyboardOk = v),
                        ),
                        _toggleChip(
                          "Mouse",
                          status.mouseOk,
                          (v) => setDialogState(() => status.mouseOk = v),
                        ),
                        _toggleChip(
                          "VGA / Display Cable",
                          status.vgaCableOk,
                          (v) => setDialogState(() => status.vgaCableOk = v),
                        ),
                        _toggleChip(
                          "Power Cable",
                          status.powerCableOk,
                          (v) => setDialogState(() => status.powerCableOk = v),
                        ),
                        _toggleChip(
                          "Ethernet / LAN",
                          status.internetCableOk,
                          (v) => setDialogState(() => status.internetCableOk = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ramC,
                            decoration: const InputDecoration(labelText: 'RAM'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ssdC,
                            decoration: const InputDecoration(labelText: 'Storage'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: osC,
                      decoration: const InputDecoration(labelText: 'Operating System'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesC,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Technician Notes / Fault Details',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Telemetry'),
                onPressed: () async {
                  await provider.updatePcStatus(
                    widget.lab.id,
                    status.pcId,
                    status
                      ..ram = ramC.text
                      ..ssd = ssdC.text
                      ..os = osC.text
                      ..notes = notesC.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${status.pcId} updated'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      selectedColor: AppTheme.successColor.withOpacity(0.18),
      checkmarkColor: AppTheme.successColor,
      onSelected: onChanged,
    );
  }

  int _rowOf(String id) {
    final parts = id.split('-');
    return parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) - 1 : 0;
  }

  int _colOf(String id) {
    final parts = id.split('-');
    return parts.length > 2 ? (int.tryParse(parts[2]) ?? 1) - 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LabProvider>();
    final bool isMobile = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lab.name),
            Text(
              "Assigned Technician: ${widget.lab.assignedTo}",
              style: const TextStyle(fontSize: 11, color: AppTheme.accentGlow),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export Lab Excel Report',
              onPressed: () async {
                final pcsMap =
                    await provider.streamLabPcStatuses(widget.lab.id).first;
                await ExportExcelService.exportLabReport(
                  lab: widget.lab,
                  pcs: pcsMap.values.toList(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lab Excel report downloaded'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<Map<String, PcStatusModel>>(
        stream: provider.streamLabPcStatuses(widget.lab.id),
        builder: (context, snapshot) {
          final pcs = Map<String, PcStatusModel>.from(snapshot.data ?? {});
          if (pcs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allList = pcs.values.toList();
          final healthyCount = allList.where(_isPcHealthy).length;
          final faultyCount = allList.length - healthyCount;

          final instructorPc = pcs.remove('IP');

          return Column(
            children: [
              // Top Telemetry & Filter Chips Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: ResponsiveWrapper(
                  padding: EdgeInsets.zero,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          "All PCs (${allList.length})",
                          "Healthy ($healthyCount)",
                          "Faulty ($faultyCount)",
                        ].map((chip) {
                          final key = chip.split(' ').first;
                          final selected = _healthFilterChip.startsWith(key);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(chip),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _healthFilterChip = key),
                            ),
                          );
                        }).toList(),
                      ),
                      const Text(
                        "Tap any workstation to inspect or toggle hardware status",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Workstation Matrix
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.2,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (instructorPc != null) ...[
                            PcTile3D(
                              pcId: 'Instructor (IP)',
                              status: instructorPc,
                              isActive: true,
                              onTap: () => _openPcDialog(context, instructorPc),
                            ),
                            const SizedBox(height: 24),
                          ],
                          ...List.generate(widget.lab.rows, (row) {
                            final rowPcs = pcs.values
                                .where((p) => _rowOf(p.pcId) == row)
                                .where((p) {
                              if (_healthFilterChip == "Healthy") {
                                return _isPcHealthy(p);
                              }
                              if (_healthFilterChip == "Faulty") {
                                return !_isPcHealthy(p);
                              }
                              return true;
                            }).toList()
                              ..sort(
                                (a, b) =>
                                    _colOf(a.pcId).compareTo(_colOf(b.pcId)),
                              );

                            if (rowPcs.isEmpty) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: rowPcs.map((pc) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      child: PcTile3D(
                                        pcId: pc.pcId,
                                        status: pc,
                                        isActive: true,
                                        onTap: () => _openPcDialog(context, pc),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
"""

FILES["lib/screens/dashboard/filter_complaints.dart"] = """import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_complaint_provider.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'complaint_detail_screen.dart';

/// Upgraded Chip-First Complaint Analytics & Export Screen
class FilterComplaintsScreen extends StatelessWidget {
  const FilterComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();

    return ChangeNotifierProvider(
      create: (_) => FilterComplaintsProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Smart Chip Filter & Export")),
        body: ResponsiveWrapper(
          child: Consumer<FilterComplaintsProvider>(
            builder: (context, prov, _) {
              final statusCounts = prov.statusCounts();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Chip-Based Dimension Selector Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "1. Choose Filter Dimension",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: prov.filterTypes.map((type) {
                              final selected = prov.filterType == type;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(type),
                                  selected: selected,
                                  onSelected: (_) => prov.setFilterType(type),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (prov.filterType != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            "2. Select ${prov.filterType}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 42,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: prov.subFilterOptions.map((val) {
                                final selected = prov.subFilter == val;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(val),
                                    selected: selected,
                                    onSelected: (_) {
                                      prov.setSubFilter(val);
                                      prov.loadData();
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: ["All", "Pending", "In Progress", "Resolved"]
                                  .map((st) {
                                final count = statusCounts[st] ?? 0;
                                final selected = prov.statusChip == st;
                                return FilterChip(
                                  label: Text("$st ($count)"),
                                  selected: selected,
                                  onSelected: (_) => prov.setStatusChip(st),
                                );
                              }).toList(),
                            ),
                            if (kIsWeb &&
                                appData.isAdmin &&
                                prov.loadedComplaints.isNotEmpty)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: const Text("Export Excel (.xlsx)"),
                                onPressed: () async {
                                  await prov.exportToExcel();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Excel report downloaded"),
                                        backgroundColor: AppTheme.successColor,
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: prov.loading
                        ? const Center(child: CircularProgressIndicator())
                        : prov.displayedComplaints.isEmpty
                            ? const Center(
                                child: Text(
                                  "Select a filter chip above to inspect tickets",
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: prov.displayedComplaints.length,
                                itemBuilder: (context, index) {
                                  final d = prov.displayedComplaints[index];
                                  final data =
                                      (d.data() as Map<String, dynamic>?) ?? {};
                                  final status =
                                      (data['status'] ?? 'Pending').toString();
                                  final color = AppTheme.getStatusColor(status);

                                  return Card(
                                    child: ListTile(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ComplaintDetailScreen(
                                            complaintId: d.id,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        (data['message'] ?? 'No message')
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          "${data['lab'] ?? ''} • ${data['issueCategory'] ?? ''} • Assigned: ${data['assignedToName'] ?? 'N/A'}",
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(color: color),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
"""


def main():
    root = Path.cwd()
    print(f"[*] Updating Flutter project in: {root}")

    # 1. Generate Custom Lottie JSON files
    lottie_dir = root / "assets" / "lottie"
    lottie_dir.mkdir(parents=True, exist_ok=True)

    (lottie_dir / "it_hub_lottie.json").write_text(
        create_lottie_json((0.06, 0.09, 0.16), (0.05, 0.65, 0.91), "pulse_hub"),
        encoding="utf-8",
    )
    (lottie_dir / "lab_twin_lottie.json").write_text(
        create_lottie_json((0.12, 0.16, 0.23), (0.39, 0.40, 0.95), "lab_grid"),
        encoding="utf-8",
    )
    (lottie_dir / "instant_chat_lottie.json").write_text(
        create_lottie_json((0.06, 0.09, 0.16), (0.06, 0.73, 0.51), "chat_sync"),
        encoding="utf-8",
    )
    print("[+] Created 3 custom Lottie JSON animations in assets/lottie/")

    # 2. Write all upgraded Dart & YAML files
    for rel_path, content in FILES.items():
        target = root / rel_path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        print(f"[+] Updated: {rel_path}")

    # 3. Package full upgraded project into a clean .zip
    zip_name = root / "Aptech_IT_Support_Upgraded.zip"
    with zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED) as zf:
        for file_path in root.rglob("*"):
            if file_path.is_file():
                rel = file_path.relative_to(root)
                rel_str = str(rel).replace("\\", "/")
                if (
                    rel_str.startswith("build/")
                    or rel_str.startswith(".dart_tool/")
                    or rel_str.startswith(".git/")
                    or file_path.name == zip_name.name
                    or file_path.name == "build_upgraded_project.py"
                ):
                    continue
                zf.write(file_path, rel)

    print(f"\n[SUCCESS] Full upgraded project packaged into: {zip_name}")
    print("Next steps: Run `flutter pub get` and `flutter run`!")


if __name__ == "__main__":
    main()