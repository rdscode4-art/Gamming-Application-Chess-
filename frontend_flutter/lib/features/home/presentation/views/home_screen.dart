import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/avatar_badge.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../matchmaking/presentation/blocs/matchmaking_bloc.dart';
import '../../../matchmaking/presentation/blocs/matchmaking_state.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/blocs/wallet_state.dart';
import '../../../wallet/presentation/blocs/wallet_event.dart';
import '../../../../core/di/service_locator.dart';
import '../../../tournament/presentation/blocs/tournament_bloc.dart';
import '../../../tournament/presentation/blocs/tournament_state.dart';
import '../blocs/home_bloc.dart';
import '../blocs/home_state.dart';
import '../../../notifications/presentation/blocs/notification_bloc.dart';
import '../../../notifications/presentation/blocs/notification_state.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkForActiveMatch();
    context.read<WalletBloc>().add(WalletFetchData());
  }

  Future<void> _checkForActiveMatch() async {
    try {
      final response = await ApiClient.instance.get('/tournaments/my-active-match');
      if (response.statusCode == 200 && response.data['activeMatch'] == true) {
        final gameId = response.data['gameId'];
        if (mounted && gameId != null) {
          context.push('/tournament-vs/$gameId');
        }
      }
    } catch (e) {
      debugPrint("Error checking active match: $e");
    }
  }

  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.purpleLight;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'emoji_events': return Icons.emoji_events;
      case 'account_balance': return Icons.account_balance;
      case 'flash_on': return Icons.flash_on;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchmakingBloc, MatchmakingState>(
      builder: (context, state) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(state),
                      _buildBannerCarousel(),
                      _buildQuickActions(),
                      _buildUpcomingTournaments(),
                      _buildLiveMatches(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(MatchmakingState state) {
    final username = state.myUsername.isNotEmpty ? state.myUsername : 'ArjunKumar';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AvatarBadge(name: username, size: 44, rating: state.myRating),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good evening,', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                  Text(
                    username,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBg : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBorder : Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, notifState) {
                      bool hasUnread = false;
                      if (notifState is NotificationLoaded) {
                        hasUnread = notifState.notifications.any((n) => !n.isRead);
                      }
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications, color: context.textPrimary, size: 18),
                          if (hasUnread)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go(AppRoutes.wallet),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.gold, size: 16),
                      const SizedBox(width: 6),
                      BlocBuilder<WalletBloc, WalletState>(
                        bloc: getIt<WalletBloc>(),
                        builder: (context, walletState) {
                          return Text(
                            '₹${walletState.totalBalance}',
                            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.gold)));
        if (state.banners.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (idx) => setState(() => _bannerIndex = idx),
                    itemCount: state.banners.length,
                    itemBuilder: (context, idx) {
                      final banner = state.banners[idx];
                      final bColor = _hexToColor(banner['color']);
                      final bIcon = _getIcon(banner['icon']);
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              bColor.withValues(alpha: 0.5),
                              AppColors.navy.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      bColor.withValues(alpha: 0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              top: 10,
                              child: Icon(bIcon, size: 80, color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                                      ),
                                      child: const Text('FEATURED', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(banner['title'] ?? '', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Rajdhani', letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text(banner['subtitle'] ?? '', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldGrad,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Text(banner['cta'] ?? '', style: const TextStyle(color: AppColors.navyDeep, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Row(
                      children: List.generate(state.banners.length, (idx) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _bannerIndex == idx ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _bannerIndex == idx ? AppColors.gold : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
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
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('QUICK PLAY', style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          // Glass Hero Play Card
          GlassCard(
            onTap: () => context.push(AppRoutes.playMode),
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.purpleLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('1 VS 1', style: TextStyle(color: AppColors.purpleLight, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          Text('PLAY ONLINE', style: TextStyle(color: context.textPrimary, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('Global Matchmaking', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 80),
                  ],
                ),
                Positioned(
                  right: -15,
                  bottom: -20,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: const Text('🎮', style: TextStyle(fontSize: 100, shadows: [Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))])),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Glass Action Cards
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('DISCOVER', style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _buildGlassAction('Create', '⚔️', AppColors.green, () => context.push(AppRoutes.createTournament)),
                const SizedBox(width: 16),
                _buildGlassAction('Wallet', '💰', const Color(0xFFFF5252), () => context.push(AppRoutes.wallet)),
                const SizedBox(width: 16),
                _buildGlassAction('Refer & Earn', '🎁', AppColors.gold, () => context.push(AppRoutes.referral)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassAction(String label, String emoji, Color color, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32, shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 6))])),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: context.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLiveMatches() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.green));
        
        final matches = state.liveMatches;
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text('LIVE MATCHES', style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                    if (matches.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.6), blurRadius: 6, spreadRadius: 2)],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${matches.length} Live', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Text('No active matches right now.', style: TextStyle(color: context.textSecondary)),
                )
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, idx) {
                      final match = matches[idx];
                      return GlassCard(
                        width: 200,
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(match['status'] ?? 'LIVE', style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(match['prize'] ?? '-', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text((match['type'] ?? '').toString().replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    AvatarBadge(name: match['p1'] ?? 'P1', size: 32),
                                    const SizedBox(height: 6),
                                    Text(match['p1'] ?? 'P1', style: TextStyle(color: context.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.purpleLight.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('VS', style: TextStyle(color: AppColors.purpleLight, fontSize: 10, fontWeight: FontWeight.w900)),
                                ),
                                Column(
                                  children: [
                                    AvatarBadge(name: match['p2'] ?? 'P2', size: 32),
                                    const SizedBox(height: 6),
                                    Text(match['p2'] ?? 'P2', style: TextStyle(color: context.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTournaments() {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        final currentUserId = StorageService.getString('USER_ID');
        final allTourneys = state.tournaments;
        
        // Only show tournaments that the user has joined
        final tourneys = allTourneys.where((t) {
          final registeredPlayers = t['registeredPlayers'] as List? ?? [];
          return currentUserId != null && registeredPlayers.any((p) {
            if (p is String) return p == currentUserId;
            if (p is Map) return p['userId'] == currentUserId || p['_id'] == currentUserId;
            return false;
          });
        }).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text('UPCOMING TOURNAMENTS', style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.tournamentsList),
                    child: const Text('View All', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.gold))
              else if (tourneys.isEmpty)
                Center(child: Text('No upcoming tournaments', style: TextStyle(color: context.textSecondary)))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tourneys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                  Text(t['name'] ?? 'Tournament', style: TextStyle(color: context.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  if (startTime != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, color: AppColors.purpleLight, size: 14),
                                        const SizedBox(width: 6),
                                        Text('Starts at ${DateFormat('MMM d, h:mm a').format(startTime)}', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
                                        child: RichText(text: TextSpan(children: [
                                          TextSpan(text: 'Entry: ', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                          TextSpan(text: '₹${t['entryFee'] ?? 0}', style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ])),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                        child: RichText(text: TextSpan(children: [
                                          TextSpan(text: 'Prize: ', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                          TextSpan(text: '₹${t['prizePool'] ?? 0}', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ])),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text('$regCount/$maxCount', style: TextStyle(color: context.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                                onTap: () => context.push(AppRoutes.tournamentDetail, extra: t['tournamentId']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold.withOpacity(0.15) : AppColors.gold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                                  ),
                                  child: const Text('View', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
