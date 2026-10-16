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
                                      child: Lottie.asset(
                                        item.lottieAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            item.fallbackIcon,
                                            size: 54,
                                            color: Colors.white,
                                          ),
                                        ),
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
