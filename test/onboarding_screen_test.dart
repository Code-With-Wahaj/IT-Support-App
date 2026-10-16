import 'package:aptech_it_support/routes/app_routes.dart';
import 'package:aptech_it_support/screens/onboarding/onboarding_screen.dart';
import 'package:aptech_it_support/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget introduction({double textScale = 1, bool reduceMotion = true}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduceMotion,
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
    home: const OnboardingScreen(),
    routes: {
      Routes.login: (_) => const Scaffold(body: Text('Login destination')),
    },
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('All three slides lead to sign in and remember completion', (
    tester,
  ) async {
    await tester.pumpWidget(introduction());
    await tester.pumpAndSettle();
    expect(find.text('Report a lab issue in seconds'), findsOneWidget);
    expect(find.text('APTECH IT HUB'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Know the health of every workstation'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Keep support in one conversation'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('has_seen_onboarding_v2'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Skip preserves the existing completion and login flow', (
    tester,
  ) async {
    await tester.pumpWidget(introduction());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('has_seen_onboarding_v2'), isTrue);
  });

  testWidgets('Only the visible onboarding animation plays', (tester) async {
    await tester.pumpWidget(introduction(reduceMotion: false));
    await tester.pump();
    final activeBefore = tester
        .widgetList<LottieBuilder>(find.byType(LottieBuilder))
        .where((animation) => animation.animate == true);
    expect(activeBefore, hasLength(1));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    final activeAfter = tester
        .widgetList<LottieBuilder>(find.byType(LottieBuilder))
        .where((animation) => animation.animate == true);
    expect(activeAfter, hasLength(1));
    expect(find.text('Know the health of every workstation'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Small phones, landscape and large text keep controls usable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(740, 360),
      const Size(800, 1024),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(introduction(textScale: 1.5));
      await tester.pumpAndSettle();
      final animation = tester.widget<LottieBuilder>(
        find.byType(LottieBuilder).first,
      );
      expect(animation.animate, isFalse);
      expect(animation.controller!.value, 0.64);
      expect(tester.getRect(find.text('Skip')).bottom, lessThan(size.height));
      expect(
        tester.getRect(find.widgetWithText(ElevatedButton, 'Next')).bottom,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull, reason: 'Layout failed at $size');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
