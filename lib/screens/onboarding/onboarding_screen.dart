import 'package:flutter/material.dart';
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
      badge: "LAB COMPLAINTS",
      title: "Report a lab issue in seconds",
      description:
          "Describe the problem with your lab or PC. IT Hub identifies the lab and issue, then notifies the assigned technician.",
      lottieAsset: "assets/lottie/it_hub_lottie.json",
      fallbackIcon: Icons.support_agent_rounded,
    ),
    _OnboardingSlide(
      badge: "LAB MANAGEMENT",
      title: "Know the health of every workstation",
      description:
          "Explore your labs, check each PC's hardware and cables, and keep specifications and fault notes up to date.",
      lottieAsset: "assets/lottie/lab_twin_lottie.json",
      fallbackIcon: Icons.grid_view_rounded,
    ),
    _OnboardingSlide(
      badge: "IT SUPPORT",
      title: "Keep support in one conversation",
      description:
          "Report issues, follow ticket progress, and coordinate with your IT team from the support chat.",
      lottieAsset: "assets/lottie/instant_chat_lottie.json",
      fallbackIcon: Icons.forum_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding_v2', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          TickerMode(
            enabled: !reduceMotion,
            child: const AnimatedNetworkBackground(
              color: AppTheme.accentColor,
              backgroundColor: AppTheme.primaryColor,
            ),
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
                      // Top Bar - Only Skip button, no logo or text
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (idx) =>
                              setState(() => _currentIndex = idx),
                          itemBuilder: (context, idx) {
                            final item = _slides[idx];
                            return SingleChildScrollView(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final size = constraints.maxWidth.clamp(
                                          0.0,
                                          320.0,
                                        );
                                        return ExcludeSemantics(
                                          child: SizedBox.square(
                                            dimension: size,
                                            child: Lottie.asset(
                                              item.lottieAsset,
                                              fit: BoxFit.contain,
                                              frameRate: FrameRate.composition,
                                              animate:
                                                  idx == _currentIndex &&
                                                  !reduceMotion,
                                              controller: reduceMotion
                                                  ? const AlwaysStoppedAnimation<
                                                      double
                                                    >(0.64)
                                                  : null,
                                              errorBuilder: (_, __, ___) =>
                                                  Center(
                                                    child: Icon(
                                                      item.fallbackIcon,
                                                      size: 64,
                                                      color:
                                                          AppTheme.accentGlow,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.accentGlow.withValues(
                                            alpha: 0.4,
                                          ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.78,
                                        ),
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

                      // Bottom Controls - Centered Progress Indicator & Next/Sign in button below it
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (i) {
                              final active = i == _currentIndex;
                              return AnimatedContainer(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 28 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.accentGlow
                                      : Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_currentIndex < _slides.length - 1) {
                                  if (reduceMotion) {
                                    _pageController.jumpToPage(_currentIndex + 1);
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeOutCubic,
                                    );
                                  }
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
                                    ? "Sign in"
                                    : "Next",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
