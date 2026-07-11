import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/leaderboard_bloc.dart';
import '../blocs/leaderboard_state.dart';
import '../blocs/leaderboard_event.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedTab = 'Global';
  final List<String> _tabs = ['Global', 'Classic', 'Rapid'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
          );
        }

        final users = state.leaderboard;
        final top3 = <Map<String, dynamic>>[];
        final others = <Map<String, dynamic>>[];

        for (int i = 0; i < users.length; i++) {
          final u = users[i];
          final rank = i + 1;
          final name = u['username'] ?? 'User';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
          final rating = '${u['rating'] ?? 1200}';
          final wins = '${u['wins'] ?? 0}';
          final cc = 'IN'; // Hardcoded for now
          final color = _getRankColor(rank);

          final playerMap = {
            'rank': rank,
            'name': name,
            'rating': rating,
            'initial': initial,
            'color': color,
            'wins': wins,
            'isYou': false, // Would need userId to match, but we don't have it in UI right now without ProfileBloc
            'cc': cc,
          };

          if (rank <= 3) {
            top3.add(playerMap);
          } else {
            others.add(playerMap);
          }
        }

        return Scaffold(
          backgroundColor: context.bgColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
                _buildTabs(),
                const SizedBox(height: 32),
                if (top3.isNotEmpty) _buildPodium(top3),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: others.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildPlayerCard(others[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return Colors.blueAccent;
    if (rank == 3) return Colors.orange;
    return AppColors.purpleLight;
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(6),
        borderRadius: 24,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedTab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selectedTab != tab) {
                    setState(() => _selectedTab = tab);
                    context.read<LeaderboardBloc>().add(LoadLeaderboard(type: tab.toLowerCase()));
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isSelected 
                        ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] 
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).scaffoldBackgroundColor 
                          : context.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                    child: Text(tab),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    final p1 = top3.firstWhere((p) => p['rank'] == 1, orElse: () => top3[0]);
    final p2 = top3.firstWhere((p) => p['rank'] == 2, orElse: () => top3.length > 1 ? top3[1] : p1);
    final p3 = top3.firstWhere((p) => p['rank'] == 3, orElse: () => top3.length > 2 ? top3[2] : p1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1) _buildPodiumItem(p2, height: 110, gradient: const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          if (top3.length > 1) const SizedBox(width: 8),
          if (top3.isNotEmpty) _buildPodiumItem(p1, height: 150, gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFDB931)], begin: Alignment.topCenter, end: Alignment.bottomCenter), isFirst: true),
          if (top3.length > 2) const SizedBox(width: 8),
          if (top3.length > 2) _buildPodiumItem(p3, height: 90, gradient: const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFA0522D)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> player, {required double height, required Gradient gradient, bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Icon(Icons.workspace_premium, color: AppColors.gold, size: 36, shadows: [Shadow(color: AppColors.gold, blurRadius: 12)]),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: isFirst ? 72 : 60,
              height: isFirst ? 72 : 60,
              decoration: BoxDecoration(
                color: player['color'] as Color, 
                shape: BoxShape.circle,
                border: Border.all(color: gradient.colors.first, width: 3),
                boxShadow: [
                  BoxShadow(color: gradient.colors.first.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Center(
                child: Text(player['initial'] as String, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Text('${player['rank']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(player['name'] as String, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(player['rating'] as String, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? gradient.colors.first.withValues(alpha: 0.1) 
                : gradient.colors.first.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: gradient.colors.first.withValues(alpha: 0.5), width: 2),
              left: BorderSide(color: gradient.colors.first.withValues(alpha: 0.2)),
              right: BorderSide(color: gradient.colors.first.withValues(alpha: 0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#${player['rank']}',
              style: TextStyle(
                color: gradient.colors.first,
                fontSize: isFirst ? 36 : 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Rajdhani',
                shadows: [Shadow(color: gradient.colors.first.withValues(alpha: 0.5), blurRadius: 10)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final isYou = player['isYou'] as bool;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Text('#${player['rank']}', style: TextStyle(color: context.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: player['color'] as Color, shape: BoxShape.circle),
            child: Center(
              child: Text(player['initial'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(player['name'] as String, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('YOU', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(player['cc'] as String, style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${player['wins']} wins', style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(player['rating'] as String, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
