import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';

class ChessGuideScreen extends StatelessWidget {
  const ChessGuideScreen({super.key});

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
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),
          if (Theme.of(context).brightness == Brightness.dark) const BgBlobs(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    children: [
                      _buildGuideSection(
                        context,
                        'The Basics of Chess',
                        'Chess is a two-player strategy board game played on a checkered board with 64 squares arranged in an 8x8 grid. The objective is to checkmate the opponent\'s king.',
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildGuideSection(
                        context,
                        'Piece Movements',
                        '• Pawn: Moves forward one square, but captures diagonally.\n'
                        '• Knight: Moves in an L-shape (two squares in one direction, then one perpendicular).\n'
                        '• Bishop: Moves diagonally any number of squares.\n'
                        '• Rook: Moves horizontally or vertically any number of squares.\n'
                        '• Queen: Combines the power of the Rook and Bishop.\n'
                        '• King: Moves one square in any direction.',
                        Icons.extension_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildGuideSection(
                        context,
                        'Special Rules',
                        '• Castling: A move to protect your king and activate your rook.\n'
                        '• En Passant: A special pawn capture rule.\n'
                        '• Promotion: When a pawn reaches the opposite end of the board, it can become any other piece (usually a Queen).',
                        Icons.star_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildGuideSection(
                        context,
                        'Basic Strategies',
                        '1. Control the center of the board.\n'
                        '2. Develop your pieces quickly.\n'
                        '3. Protect your King (castle early).\n'
                        '4. Don\'t give away your pieces for free.',
                        Icons.lightbulb_outline_rounded,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Chess Guide',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context, String title, String content, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
