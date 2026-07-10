import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_router.dart';
import 'dart:ui';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.sports_esports, // using gamepad as knight substitute
      'color': AppColors.blue,
      'step': '01  •  PLAY',
      'title': 'Real chess.\nReal opponents.',
      'desc': 'Face verified players in rapid, blitz and classic formats. Every game rated, every game ranked.',
    },
    {
      'icon': Icons.emoji_events,
      'color': AppColors.gold,
      'step': '02  •  COMPETE',
      'title': 'Paid tournaments\nfrom ₹25 to ₹5,000.',
      'desc': 'Join public arenas or create private contests. Fair matchmaking, transparent prize pools.',
    },
    {
      'icon': Icons.layers, // using layers/diamond as win icon substitute
      'color': AppColors.green,
      'step': '03  •  WIN',
      'title': 'Withdraw cash\ninstantly to UPI.',
      'desc': 'Your winnings, your money. Verified withdrawals to any Indian bank or UPI in minutes.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: context.isDark ? [AppColors.navy.withOpacity(0.8), AppColors.navyDeep] : [Colors.white, const Color(0xFFF5F5F5)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, idx) {
                      final slide = _slides[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: context.isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: context.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: (slide['color'] as Color).withOpacity(0.4), blurRadius: 50, spreadRadius: 10),
                                      ],
                                    ),
                                  ),
                                  Icon(slide['icon'] as IconData, color: slide['color'] as Color, size: 60),
                                ],
                              ),
                            ),
                            Text(
                              slide['step'] as String,
                              style: TextStyle(color: context.textSecondary, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: context.textPrimary, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', height: 1.1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['desc'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: context.textSecondary, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentPage == _slides.length - 1;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (idx) {
              final active = _currentPage == idx;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : (context.isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isLast ? AppColors.gold : (context.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(24),
                border: isLast ? null : Border.all(color: context.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(
                  isLast ? 'Get Started' : 'Continue',
                  style: TextStyle(
                    color: isLast ? AppColors.navyDeep : context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
