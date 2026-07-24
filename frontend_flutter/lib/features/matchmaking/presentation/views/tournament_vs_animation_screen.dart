import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/network/api_client.dart';

class TournamentMatchmakingAnimationScreen extends StatefulWidget {
  final String gameId;

  const TournamentMatchmakingAnimationScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<TournamentMatchmakingAnimationScreen> createState() =>
      _TournamentMatchmakingAnimationScreenState();
}

class _TournamentMatchmakingAnimationScreenState
    extends State<TournamentMatchmakingAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fetchMatchDataAndNavigate();
  }

  Future<void> _fetchMatchDataAndNavigate() async {
    try {
      // Small artificial delay to show animation for at least 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      final response = await ApiClient.instance.get('/tournaments/match/${widget.gameId}');
      if (response.statusCode == 200 && mounted) {
        final matchData = response.data;
        context.pushReplacement('/game', extra: matchData);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load match details.')),
          );
          context.go('/tournaments');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/tournaments');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cool spinning chess piece or VS logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (_controller.value * 0.5),
                  child: Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.sports_esports,
                size: 100,
                color: Color(0xFFE4A11B),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'TOURNAMENT MATCH',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your match is starting...',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
