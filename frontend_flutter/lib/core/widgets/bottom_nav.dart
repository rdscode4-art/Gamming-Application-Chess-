import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'dart:ui';
import '../../../routes/app_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: context.glassBgColor,
        border: Border(top: BorderSide(color: context.glassBorderColor)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItem(context, Icons.home_outlined, Icons.home, 'Home', AppRoutes.home, location),
                _buildItem(context, Icons.emoji_events_outlined, Icons.emoji_events, 'Tournaments', AppRoutes.tournamentsList, location),
                _buildCenterItem(context, Icons.play_arrow, AppRoutes.playMode, location),
                _buildItem(context, Icons.bar_chart, Icons.bar_chart, 'Leaderboard', AppRoutes.leaderboard, location),
                _buildItem(context, Icons.person_outline, Icons.person, 'Profile', AppRoutes.profile, location),
              ],
            ),
            ), // closes Padding
          ), // closes SafeArea
        ), // closes ClipRRect
      ); // closes Container
  }

  Widget _buildItem(BuildContext context, IconData inactiveIcon, IconData activeIcon, String label, String route, String currentLoc) {
    final isActive = currentLoc == route;
    final color = isActive ? AppColors.gold : context.textSecondary;
    final icon = isActive ? activeIcon : inactiveIcon;
    
    return GestureDetector(
      onTap: () {
        if (!isActive && route.isNotEmpty) {
           context.go(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(BuildContext context, IconData icon, String route, String currentLoc) {
    return GestureDetector(
      onTap: () {
        if (currentLoc != route) context.go(route);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: const Icon(Icons.play_arrow, color: AppColors.navyDeep, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
