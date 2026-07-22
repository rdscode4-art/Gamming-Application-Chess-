import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/avatar_badge.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../../../../routes/app_router.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../../profile/presentation/blocs/profile_state.dart';
import '../../../profile/presentation/blocs/profile_event.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic>? matchData;
  const GameScreen({super.key, this.matchData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ChessBoardController chessController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _getPref(BuildContext context, String key, bool defaultValue) {
    final state = context.read<ProfileBloc>().state;
    final prefs = state.userProfile?['preferences'];
    if (prefs != null && prefs[key] != null) return prefs[key];
    return defaultValue;
  }

  void _playFeedback() async {
    if (_getPref(context, 'moveVibration', true)) {
      HapticFeedback.mediumImpact();
    }
    if (_getPref(context, 'gameSounds', true)) {
      try {
        await _audioPlayer.play(AssetSource('sounds/move.wav'));
      } catch (e) {
        debugPrint('Failed to play sound: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    chessController = ChessBoardController();
    if (widget.matchData != null) {
      context.read<GameBloc>().add(GameInitData(widget.matchData!));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.fen != null && state.fen != chessController.game.fen) {
          chessController.loadFen(state.fen!);
          _playFeedback();
        }
        if (state.isGameOver) {
          // Route to victory screen immediately
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go(AppRoutes.victory, extra: state.gameResult);
          });
        }
        if (state.showDrawDialog) {
          context.read<GameBloc>().add(GameClearDrawOffer());
          _showDrawDialog(context);
        }
      },
      builder: (context, state) {
        final urgent = state.myTime < 30;
        return WillPopScope(
          onWillPop: () async {
            if (state.isGameOver) return true;
            
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBg : Colors.white,
                title: Text('Resign Game?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                content: Text('Are you sure you want to leave? This will count as a resignation and you will lose the game.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true), 
                    child: const Text('Resign', style: TextStyle(color: AppColors.red)),
                  ),
                ],
              ),
            );
            
            if (confirm == true) {
              context.read<GameBloc>().add(GameResign());
              return true;
            }
            return false;
          },
          child: Scaffold(
            backgroundColor: context.bgColor,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [Theme.of(context).brightness == Brightness.dark ? AppColors.purpleLight.withValues(alpha: 0.15) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Opponent Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AvatarBadge(name: state.opponentName.isNotEmpty ? state.opponentName : 'Opponent', size: 40, rating: state.opponentRating),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.opponentName.isNotEmpty ? state.opponentName : 'Opponent', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text('Rating: ${state.opponentRating} • Global', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _fmt(state.opponentTime),
                              style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'JetBrains Mono'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Opponent captures
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('♙♙♙', style: TextStyle(color: context.textPrimary.withValues(alpha: 0.6), fontSize: 16)),
                      ),
                    ),

                    // Board
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 2),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? AppColors.purpleLight.withValues(alpha: 0.3) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: -5),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ChessBoard(
                              controller: chessController,
                              boardColor: BoardColor.brown,
                              boardOrientation: state.playerColor == 'black' ? PlayerColor.black : PlayerColor.white,
                              enableUserMoves: state.isMyTurn, // Prevents moving opponent's pieces
                              onMove: () {
                                final history = chessController.game.history;
                                if (history.isNotEmpty) {
                                  final move = history.last.move;
                                  _playFeedback();
                                  context.read<GameBloc>().add(GameMakeMove(
                                        from: move.fromAlgebraic,
                                        to: move.toAlgebraic,
                                        promotion: move.promotion != null ? 'q' : null,
                                      ));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Player captures
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('♟♟', style: TextStyle(color: context.textPrimary.withValues(alpha: 0.6), fontSize: 16)),
                      ),
                    ),

                    // Player Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AvatarBadge(name: state.myUsername.isNotEmpty ? state.myUsername : 'You', size: 40, rating: state.myRating),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: '${state.myUsername.isNotEmpty ? state.myUsername : 'You'} ', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                                        const TextSpan(text: '(You)', style: TextStyle(color: AppColors.green, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text('Rating: ${state.myRating} • Global', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: urgent ? AppColors.red.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: urgent ? AppColors.red : Theme.of(context).colorScheme.primary, width: 2),
                              boxShadow: urgent ? [BoxShadow(color: AppColors.red.withValues(alpha: 0.4), blurRadius: 12)] : [],
                            ),
                            child: Text(
                              _fmt(state.myTime),
                              style: TextStyle(
                                color: urgent ? AppColors.red : Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAction(Icons.flag, 'Resign', AppColors.red, () {
                            _showResignDialog(context);
                          }),
                          _buildAction(Icons.replay, 'Draw', Theme.of(context).colorScheme.primary, () {
                            _showOfferDrawConfirmationDialog(context);
                          }),
                          _buildAction(Icons.chat_bubble_outline, 'Chat', Colors.blue, () {
                            context.read<GameBloc>().add(GameChatOpened());
                            _showChatBottomSheet(context).whenComplete(() {
                              if (context.mounted) {
                                context.read<GameBloc>().add(GameChatClosed());
                              }
                            });
                          }, hasBadge: state.hasUnreadMessages),
                          _buildAction(Icons.settings, 'Settings', context.textSecondary, () {
                            _showSettingsBottomSheet(context);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildAction(IconData icon, String label, Color color, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (hasBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showResignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text('Resign Game?', style: TextStyle(color: context.textPrimary)),
        content: Text('Are you sure you want to resign and forfeit the game?', style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameBloc>().add(GameResign());
            },
            child: const Text('Resign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOfferDrawConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text('Offer Draw?', style: TextStyle(color: context.textPrimary)),
        content: Text('Are you sure you want to offer a draw to your opponent?', style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameBloc>().add(GameOfferDraw());
            },
            child: Text('Offer', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _showChatBottomSheet(BuildContext context) {
    final textController = TextEditingController();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.5,
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chat', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: context.textSecondary)),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<GameBloc, GameState>(
                    bloc: context.read<GameBloc>(),
                    builder: (context, state) {
                      if (state.chatMessages.isEmpty) {
                        return Center(child: Text('No messages yet', style: TextStyle(color: context.textSecondary)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = state.chatMessages[index];
                          final isMe = msg['byUserId'] == state.myUserId;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isMe ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isMe ? 'You' : (msg['byUsername'] ?? 'Opponent'), style: TextStyle(color: isMe ? Theme.of(context).colorScheme.primary : context.textSecondary, fontSize: 10)),
                                  const SizedBox(height: 2),
                                  Text(msg['message'] ?? '', style: TextStyle(color: context.textPrimary, fontSize: 14)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  bottom: true,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: TextStyle(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: context.textSecondary),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary, size: 20),
                                onPressed: () {
                                  if (textController.text.trim().isNotEmpty) {
                                    context.read<GameBloc>().add(GameSendChat(textController.text));
                                    textController.clear();
                                  }
                                },
                              ),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                context.read<GameBloc>().add(GameSendChat(val));
                                textController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDrawDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text('Draw Offered', style: TextStyle(color: context.textPrimary)),
        content: Text('Your opponent has offered a draw. Do you accept?', style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameBloc>().add(GameDeclineDraw());
            },
            child: const Text('Decline', style: TextStyle(color: AppColors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameBloc>().add(GameAcceptDraw());
            },
            child: const Text('Accept', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: context.textSecondary)),
                    ],
                  ),
                ),
                BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: context.read<ProfileBloc>(),
                  builder: (context, state) {
                    final gameSounds = _getPref(context, 'gameSounds', true);
                    final moveVibration = _getPref(context, 'moveVibration', true);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildSwitchTile(context, Icons.volume_up_outlined, 'Game Sounds', gameSounds, (val) {
                            context.read<ProfileBloc>().add(UpdatePreferences({'gameSounds': val}));
                          }),
                          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
                          _buildSwitchTile(context, Icons.vibration_outlined, 'Move Vibration', moveVibration, (val) {
                            context.read<ProfileBloc>().add(UpdatePreferences({'moveVibration': val}));
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: context.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
