import 'package:flutter/material.dart';
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
            scrollBehavior: const NoScrollbarBehavior(),
            initialRoute: Routes.splash,
            routes: routes,
          );
        },
      ),
    );
  }
}

/// Completely hides all scrollbars across all scrollable widgets, chips, and lists
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
