import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_router.dart';
import 'dart:async';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/socket_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward().then((_) {
      final token = StorageService.getString(AppConstants.tokenKey);
      final isComplete = StorageService.getBool('IS_PROFILE_COMPLETE') ?? false;
      if (token != null && token.isNotEmpty && isComplete) {
        // Connect socket explicitly since user is already logged in
        SocketService().connect();
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: context.isDark ? [AppColors.navy.withOpacity(0.8), AppColors.navyDeep] : [Colors.white, const Color(0xFFF5F5F5)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _buildLogo(),
                  const SizedBox(height: 60),
                  const Text(
                    'C H E C K M A T E',
                    style: TextStyle(color: AppColors.gold, fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ROYALE',
                    style: TextStyle(color: AppColors.goldLight, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'REAL MONEY  •  REAL CHESS',
                    style: TextStyle(color: AppColors.gold, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(flex: 2),
                  _buildProgressBar(),
                  const SizedBox(height: 40),

                  const Spacer(flex: 1),
                  Text(
                    'V 1 . 0   •   M A D E   F O R   G R A N D M A S T E R S',
                    style: TextStyle(color: context.textSecondary, fontSize: 10, letterSpacing: 3),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.1), width: 1),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purpleLight.withOpacity(0.2), width: 1),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: const Center(
              child: Icon(Icons.emoji_events, color: AppColors.goldLight, size: 56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnim.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [AppColors.purpleLight, AppColors.gold, AppColors.green],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              final pct = (_progressAnim.value * 100).toInt();
              return Text(
                'LOADING  •  $pct%',
                style: TextStyle(color: context.textSecondary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }
}
