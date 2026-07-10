import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/services/storage_service.dart';

class VictoryScreen extends StatelessWidget {
  final Map<String, dynamic>? gameResult;
  const VictoryScreen({super.key, this.gameResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildTrophyAndTitle(context),
              const SizedBox(height: 40),
              _buildStatGrid(context),
              const SizedBox(height: 24),
              _buildMatchSummary(context),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  bool _isMyWin() {
    if (gameResult == null) return false;
    final myId = StorageService.getString('USER_ID') ?? '';
    final myName = StorageService.getString('USERNAME') ?? '';
    final winnerColor = gameResult!['winner'];
    if (winnerColor == 'draw') return false;
    
    final wp = gameResult!['whitePlayer'];
    final bp = gameResult!['blackPlayer'];
    
    if (winnerColor == 'white' && wp != null && (wp['userId'] == myId || wp['username'] == myName)) return true;
    if (winnerColor == 'black' && bp != null && (bp['userId'] == myId || bp['username'] == myName)) return true;
    return false;
  }

  bool _isDraw() => gameResult?['winner'] == 'draw';

  Widget _buildTrophyAndTitle(BuildContext context) {
    final bool isWin = _isMyWin();
    final bool isDraw = _isDraw();
    
    String emoji = isWin ? '🏆' : (isDraw ? '🤝' : '💔');
    String title = isWin ? 'VICTORY!' : (isDraw ? 'DRAW' : 'DEFEAT');
    Color titleColor = isWin ? Theme.of(context).colorScheme.primary : (isDraw ? Colors.blueAccent : AppColors.red);

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            fontFamily: 'Rajdhani',
            letterSpacing: 2.0,
            shadows: [BoxShadow(color: titleColor.withOpacity(0.5), blurRadius: 20)],
          ),
        ),
        if (gameResult != null && gameResult!['reason'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'by ${gameResult!['reason']}',
              style: TextStyle(color: context.textSecondary, fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    if (gameResult == null) return const SizedBox.shrink();
    
    final myId = StorageService.getString('USER_ID') ?? '';
    final myName = StorageService.getString('USERNAME') ?? '';
    final wp = gameResult!['whitePlayer'];
    final bp = gameResult!['blackPlayer'];
    
    final bool amIWhite = (wp != null && (wp['userId'] == myId || wp['username'] == myName));
    final myColorStr = amIWhite ? 'white' : 'black';
    
    String ratingChangeStr = 'N/A';
    Color ratingColor = context.textSecondary;
    
    final elo = gameResult!['eloChanges'];
    if (elo != null && elo[myColorStr] != null) {
      final delta = elo[myColorStr]['delta'];
      if (delta > 0) {
        ratingChangeStr = '+$delta';
        ratingColor = AppColors.green;
      } else if (delta < 0) {
        ratingChangeStr = '$delta';
        ratingColor = AppColors.red;
      } else {
        ratingChangeStr = '0';
        ratingColor = context.textPrimary;
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StatCard(value: ratingChangeStr, label: 'Rating Change', color: ratingColor),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _StatCard(value: 'Check', label: 'Wallet', color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchSummary(BuildContext context) {
    if (gameResult == null) return const SizedBox.shrink();
    
    final wp = gameResult!['whitePlayer'];
    final bp = gameResult!['blackPlayer'];
    
    final wName = wp?['username'] ?? 'White';
    final bName = bp?['username'] ?? 'Black';
    final elo = gameResult!['eloChanges'];
    
    String getEloStr(String color) {
      if (elo == null || elo[color] == null) return 'Casual';
      final b = elo[color]['before'];
      final a = elo[color]['after'];
      return '$b → $a';
    }
    
    Color getEloColor(String color) {
      if (elo == null || elo[color] == null) return context.textSecondary;
      final d = elo[color]['delta'];
      if (d > 0) return AppColors.green;
      if (d < 0) return AppColors.red;
      return context.textPrimary;
    }
    
    final winner = gameResult!['winner'];
    String scoreStr = '½ - ½';
    if (winner == 'white') scoreStr = '1 - 0';
    if (winner == 'black') scoreStr = '0 - 1';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Match Summary', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(winner?.toUpperCase() ?? 'DRAW', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlayerInfo(context, wName.isNotEmpty ? wName[0] : 'W', wName, getEloStr('white'), AppColors.purpleLight, getEloColor('white')),
              Column(
                children: [
                  Text(scoreStr, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani')),
                  const SizedBox(height: 4),
                  Text('Completed', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                ],
              ),
              _buildPlayerInfo(context, bName.isNotEmpty ? bName[0] : 'B', bName, getEloStr('black'), Colors.black, getEloColor('black')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context, String initial, String name, String ratingChange, Color avatarColor, Color ratingColor) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
          child: Center(
            child: Text(initial.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(ratingChange, style: TextStyle(color: ratingColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.playMode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('Play Again', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text('Home', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani')),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
