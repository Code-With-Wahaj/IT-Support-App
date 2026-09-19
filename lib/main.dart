
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aptech_it_support/providers/filter_complaint_provider.dart';
import 'package:aptech_it_support/providers/lab_provider.dart';
import 'package:aptech_it_support/theme/app_theme.dart';
import 'firebase_options.dart';

import 'package:aptech_it_support/routes/app_routes.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => FilterComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => LabProvider()..fetchLabs()),
        // Add more providers here if needed
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aptech IT Support',
            theme: AppTheme.lightTheme,
            initialRoute: Routes.splash,
            routes: routes,
          );
        },
      ),
    );
  }
}
