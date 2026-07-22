import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../blocs/notification_bloc.dart';
import '../blocs/notification_event.dart';
import '../blocs/notification_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationBloc>()..add(LoadNotifications()),
      child: Scaffold(
        backgroundColor: context.bgColor,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: context.isDark ? AppColors.navyGrad : null)),
            const BgBlobs(),
            SafeArea(
              child: Column(
                children: [
                  BackHeader(title: 'Notifications', onBack: () => context.pop()),
                  Expanded(
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        if (state is NotificationLoading || state is NotificationInitial) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is NotificationError) {
                          return Center(child: Text('Error: ${state.message}', style: TextStyle(color: context.textPrimary)));
                        } else if (state is NotificationLoaded) {
                          final notifications = state.notifications;
                          
                          if (notifications.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('📭', style: TextStyle(fontSize: 64)),
                                  const SizedBox(height: 16),
                                  Text('No notifications yet', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('We\'ll let you know when something happens.', style: TextStyle(color: context.textSecondary, fontSize: 14)),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              final bool isRead = notif.isRead;
                              
                              // Determine icon and color based on type
                              String icon = '🔔';
                              Color iconColor = AppColors.blue;
                              
                              switch (notif.type) {
                                case 'wallet_credit':
                                  icon = '💰';
                                  iconColor = AppColors.green;
                                  break;
                                case 'wallet_debit':
                                  icon = '💸';
                                  iconColor = AppColors.red;
                                  break;
                                case 'match_found':
                                  icon = '⚔️';
                                  iconColor = AppColors.gold;
                                  break;
                                case 'tournament_start':
                                  icon = '🏆';
                                  iconColor = AppColors.purpleLight;
                                  break;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isRead) {
                                      context.read<NotificationBloc>().add(MarkNotificationAsRead(notif.id));
                                    }
                                  },
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
                                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
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
                                                      notif.title,
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
                                              Text(notif.body, style: TextStyle(color: isRead ? context.textSecondary : context.textPrimary.withValues(alpha: 0.9), fontSize: 13, height: 1.4)),
                                              const SizedBox(height: 8),
                                              Text(timeago.format(notif.createdAt), style: TextStyle(color: context.textSecondary.withValues(alpha: 0.7), fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
