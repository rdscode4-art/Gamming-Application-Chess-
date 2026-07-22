import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../routes/app_router.dart';
import '../../../tournament/presentation/blocs/tournament_bloc.dart';
import '../../../tournament/presentation/blocs/tournament_state.dart';

class TournamentsListScreen extends StatelessWidget {
  const TournamentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.navyGrad 
                  : const LinearGradient(colors: [Colors.white, Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            )
          ),
          if (Theme.of(context).brightness == Brightness.dark) const BgBlobs(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All Tournaments',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<TournamentBloc, TournamentState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                      }
                      
                      final tourneys = state.tournaments;
                      if (tourneys.isEmpty) {
                        return Center(
                          child: Text('No tournaments available', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tourneys.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, idx) {
                          final t = tourneys[idx];
                          final regCount = (t['registeredPlayers'] as List?)?.length ?? 0;
                          final maxCount = t['maxPlayers'] ?? 8;
                          final progress = regCount / maxCount;
                          
                          DateTime? startTime;
                          if (t['startTime'] != null) {
                            startTime = DateTime.tryParse(t['startTime']);
                          }

                          return GestureDetector(
                            onTap: () => context.push(AppRoutes.tournamentDetail, extra: t['tournamentId']),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['name'] ?? 'Tournament', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        if (startTime != null)
                                          Row(
                                            children: [
                                              const Icon(Icons.schedule, color: AppColors.purpleLight, size: 14),
                                              const SizedBox(width: 6),
                                              Text('Starts at ${DateFormat('MMM d, h:mm a').format(startTime)}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                                              child: RichText(text: TextSpan(children: [
                                                TextSpan(text: 'Entry: ', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                                                TextSpan(text: '₹${t['entryFee'] ?? 0}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13, fontWeight: FontWeight.bold)),
                                              ])),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                              child: RichText(text: TextSpan(children: [
                                                TextSpan(text: 'Prize: ', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                                                TextSpan(text: '₹${t['prizePool'] ?? 0}', style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                                              ])),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                                                  minHeight: 8,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text('$regCount/$maxCount', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold.withValues(alpha: 0.15) : AppColors.gold.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                                    ),
                                    child: const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
