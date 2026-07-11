import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications for UI
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Tournament Starting Soon!',
        'message': 'Your Weekly Blitz tournament begins in 15 minutes. Get ready!',
        'time': '10 mins ago',
        'icon': '🏆',
        'color': AppColors.gold,
        'isRead': false,
      },
      {
        'title': 'Referral Bonus Added',
        'message': 'You received ₹50 bonus because your friend played their first match.',
        'time': '2 hours ago',
        'icon': '💰',
        'color': AppColors.green,
        'isRead': false,
      },
      {
        'title': 'Match Won',
        'message': 'You won against @chessmaster99. +25 rating points!',
        'time': 'Yesterday',
        'icon': '⚔️',
        'color': AppColors.blue,
        'isRead': true,
      },
      {
        'title': 'New Feature Update',
        'message': 'Check out our new 3D graphics and improved matchmaking speed.',
        'time': '2 days ago',
        'icon': '🚀',
        'color': AppColors.purpleLight,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.isDark ? AppColors.navyGrad : null)),
          const BgBlobs(),
          SafeArea(
            child: Column(
              children: [
                BackHeader(title: 'Notifications', onBack: () => context.pop()),
                if (notifications.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('s📭', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text('No notifications yet', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('We\'ll let you know when something happens.', style: TextStyle(color: context.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final bool isRead = notif['isRead'] as bool;
                        final Color iconColor = notif['color'] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text(notif['icon'] as String, style: const TextStyle(fontSize: 24))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif['title'] as String,
                                              style: TextStyle(color: context.textPrimary, fontSize: 15, fontWeight: isRead ? FontWeight.w600 : FontWeight.bold),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: 0.5), blurRadius: 4)]),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(notif['message'] as String, style: TextStyle(color: isRead ? context.textSecondary : context.textPrimary.withValues(alpha: 0.9), fontSize: 13, height: 1.4)),
                                      const SizedBox(height: 8),
                                      Text(notif['time'] as String, style: TextStyle(color: context.textSecondary.withValues(alpha: 0.7), fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
