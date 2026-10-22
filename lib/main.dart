import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_guard.dart';
import 'providers/auth_provider.dart';
import 'providers/app_data_provider.dart';
import 'providers/filter_complaint_provider.dart';
import 'providers/lab_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload asset bytes into memory bundle so images decode with 0ms pop-in
  rootBundle.load('assets/logo.png').catchError((_) => ByteData(0));
  rootBundle.load('assets/aptech_logo.png').catchError((_) => ByteData(0));
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
        ChangeNotifierProvider(create: (_) => LabProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          // On Web and Desktop, cap Sizer baseline dimensions so .sp, .h, and .w
          // don't blow up with desktop screen resolutions, keeping UI fixed & clean.
          if (deviceType == ScreenType.desktop || Device.width > 500) {
            Device.width = 412.0;
            Device.height = 892.0;
            Device.safeWidth = 412.0;
            Device.safeHeight = 892.0;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aptech Network Hub',
            color: AppTheme.primaryColor,
            theme: AppTheme.lightTheme,
            scrollBehavior: const NoScrollbarBehavior(),
            onGenerateInitialRoutes: (initialRouteName) {
              return [
                MaterialPageRoute(
                  builder: (_) => SplashScreen(targetRoute: initialRouteName),
                  settings: const RouteSettings(name: Routes.splash),
                ),
              ];
            },
            onGenerateRoute: AppRouteGuard.generateRoute,
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
