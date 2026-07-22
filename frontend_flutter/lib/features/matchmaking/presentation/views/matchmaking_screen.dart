import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_router.dart';
import '../blocs/matchmaking_bloc.dart';
import '../blocs/matchmaking_event.dart';
import '../blocs/matchmaking_state.dart';
import '../../../../core/services/storage_service.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _dots = 0;

  bool _isMatchFound = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  Map<String, dynamic>? _foundData;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && !_isMatchFound) {
        setState(() {
          _dots = (_dots + 1) % 4;
        });
      }
    });

    // Handle race condition: If match was found instantly before screen pushed
    final state = context.read<MatchmakingBloc>().state;
    if (state.matchFoundData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isMatchFound) {
          _startCountdown(state.matchFoundData!);
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(Map<String, dynamic> data) {
    setState(() {
      _isMatchFound = true;
      _foundData = data;
      _countdown = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          timer.cancel();
          context.go(AppRoutes.game, extra: _foundData);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isMatchFound) return false; // Prevent backing out during VS countdown
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBg : Colors.white,
            title: Text('Cancel Matchmaking?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            content: Text('Are you sure you want to stop searching for a match?', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true), 
                child: const Text('Yes', style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          context.read<MatchmakingBloc>().add(MatchmakingSearchCancelled());
          return true;
        }
        return false;
      },
      child: BlocConsumer<MatchmakingBloc, MatchmakingState>(
        listener: (context, state) {
          if (state.matchFoundData != null && !_isMatchFound) {
            _startCountdown(state.matchFoundData!);
          }
        },
        builder: (context, state) {
          if (_isMatchFound && _foundData != null) {
            return _buildVSScreen();
          }
          return _buildSearchingScreen(state);
        }
      ),
    );
  }

  Widget _buildVSScreen() {
    final wp = _foundData!['whitePlayer'];
    final bp = _foundData!['blackPlayer'];
    
    final wName = wp?['username'] ?? 'White';
    final wRating = wp?['rating'] ?? 1500;
    
    final bName = bp?['username'] ?? 'Black';
    final bRating = bp?['rating'] ?? 1500;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MATCH FOUND!',
                style: TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', letterSpacing: 2),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPlayerAvatar(wName.isNotEmpty ? wName[0] : 'W', wName, wRating.toString(), AppColors.purpleLight),
                  const Text('VS', style: TextStyle(color: AppColors.red, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', fontStyle: FontStyle.italic)),
                  _buildPlayerAvatar(bName.isNotEmpty ? bName[0] : 'B', bName, bRating.toString(), Colors.black),
                ],
              ),
              const SizedBox(height: 80),
              Text(
                'Starting in $_countdown...',
                style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(String initial, String name, String rating, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Center(
            child: Text(initial.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Rating: $rating', style: TextStyle(color: context.textSecondary, fontSize: 14)),
      ],
    );
  }

  Widget _buildSearchingScreen(MatchmakingState state) {
    final dotsStr = List.filled(_dots, '.').join();
    final mode = state.selectedMode;
    
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Finding Opponent$dotsStr',
                style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani'),
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 240,
                width: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseRing(0.0),
                    _buildPulseRing(0.33),
                    _buildPulseRing(0.66),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.notifications_active, color: AppColors.gold, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Skill Range', '${state.myRating - 200} – ${state.myRating + 200}', context.textPrimary, context),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Wait Time',
                      '${(state.searchElapsed ~/ 60).toString().padLeft(2, '0')}:${(state.searchElapsed % 60).toString().padLeft(2, '0')}',
                      Theme.of(context).colorScheme.primary,
                      context,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Format', mode != null ? '${mode.label} • ${mode.isPaid ? '₹${mode.entryFee}' : 'Free'}' : 'Searching...', context.textPrimary, context),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12, height: 1),
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('Estimated wait: 15–45 seconds', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () {
                  context.read<MatchmakingBloc>().add(MatchmakingSearchCancelled());
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.playMode);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.close, color: AppColors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Cancel Search', style: TextStyle(color: AppColors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing(double delayOffset) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double value = (_pulseController.value + delayOffset) % 1.0;
        return Opacity(
          opacity: 1.0 - value,
          child: Container(
            width: 80 + (value * 160),
            height: 80 + (value * 160),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purpleLight.withOpacity(0.5), width: 1.5),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
