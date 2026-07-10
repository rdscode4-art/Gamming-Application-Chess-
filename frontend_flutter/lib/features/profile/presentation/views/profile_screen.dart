import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
          );
        }
        
        final user = state.userProfile ?? {};
        final games = state.matchHistory ?? [];
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopSection(context, user),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, user, games),
                  const SizedBox(height: 24),
                  _buildAchievementsSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopSection(BuildContext context, Map<String, dynamic> user) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.settings),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.settings, color: Theme.of(context).iconTheme.color, size: 20),
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user['username'] as String?)?.isNotEmpty == true ? (user['username'] as String)[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                ),
                child: Icon(Icons.emoji_events, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user['username'] ?? 'User',
          style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user['username'] ?? 'user'} • IN',
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTopStat(context, '${user['rating'] ?? 1200}', 'Rating', AppColors.gold),
            _buildVerticalDivider(context),
            _buildTopStat(context, '₹${user['totalBalance'] ?? 0}', 'Balance', AppColors.green),
            _buildVerticalDivider(context),
            _buildTopStat(context, _getRankString(user['rating'] ?? 1200), 'Rank', context.textPrimary),
          ],
        ),
      ],
    );
  }

  String _getRankString(int rating) {
    if (rating < 1200) return 'Bronze';
    if (rating < 1500) return 'Silver';
    if (rating < 1800) return 'Gold';
    if (rating < 2100) return 'Diamond';
    return 'Master';
  }

  Widget _buildTopStat(BuildContext context, String value, String label, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> user, List<dynamic> games) {
    int wins = user['wins'] ?? 0;
    int losses = user['losses'] ?? 0;
    int draws = user['draws'] ?? 0;
    int played = wins + losses + draws;
    double winRate = played > 0 ? (wins / played) * 100 : 0.0;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildGridStat('$played', 'Played', context.textPrimary, context),
        _buildGridStat('$wins', 'Wins', AppColors.green, context),
        _buildGridStat('$losses', 'Losses', AppColors.red, context),
        _buildGridStat('$draws', 'Draws', context.textPrimary, context),
        _buildGridStat('${winRate.toStringAsFixed(1)}%', 'Win Rate', AppColors.gold, context),
        _buildGridStat('0', 'Tourney Wins', AppColors.purpleLight, context),
      ],
    );
  }

  Widget _buildGridStat(String value, String label, Color valueColor, BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildAchievementCard('100 Wins', 'Win 100 matches', Icons.emoji_events, AppColors.gold, true, context),
            _buildAchievementCard('Rapid Master', 'Win 50 rapid games', Icons.flash_on, Colors.redAccent, true, context),
            _buildAchievementCard('Classic Champion', 'Win a classic tournament', Icons.account_balance, context.textSecondary, false, context),
            _buildAchievementCard('Sharpshooter', '90%+ accuracy 10 times', Icons.adjust, context.textSecondary, false, context),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String sub, IconData icon, Color iconColor, bool earned, BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Opacity(
        opacity: earned ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: context.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: context.textSecondary, fontSize: 10)),
              ],
            ),
            if (earned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('EARNED', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              )
            else
              const SizedBox(height: 20), // Placeholder for alignment
          ],
        ),
      ),
    );
  }
}
