import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../tournament/presentation/blocs/tournament_bloc.dart';
import '../../../tournament/presentation/blocs/tournament_event.dart';
import '../../../tournament/presentation/blocs/tournament_state.dart';
import '../../../../core/services/storage_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TournamentBloc, TournamentState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          Fluttertoast.showToast(
            msg: state.successMessage!,
            backgroundColor: AppColors.green,
          );
          context.read<TournamentBloc>().add(ClearTournamentMessages());
        }
        if (state.error != null) {
          Fluttertoast.showToast(
            msg: state.error!,
            backgroundColor: AppColors.red,
          );
          context.read<TournamentBloc>().add(ClearTournamentMessages());
        }
      },
      builder: (context, state) {
        final t = state.currentTournament;
        if (state.isLoading || t == null) {
          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.bgColor,
          body: Column(
            children: [
              _buildHeader(context, t),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatCards(context, t),
                      const SizedBox(height: 24),
                      _buildRegistrationProgress(context, t),
                      const SizedBox(height: 24),
                      _buildRules(context, t),
                      const SizedBox(height: 24),
                      _buildRegisteredPlayers(context, t),
                      const SizedBox(height: 100), // padding for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(
            context,
            t,
            state.isActionLoading,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.purple
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            bottom: -40,
            child: Icon(
              Icons.emoji_events,
              size: 120,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final name = t['name'] ?? 'Tournament';
                      final prize = t['prizePool'] ?? 0;
                      final id = t['tournamentId'] ?? '';
                      Share.share(
                        '🏆 Join the "$name" tournament on Checkmate!\n\n'
                        '💰 Prize Pool: ₹$prize\n'
                        '👉 Sign up now and play: https://checkmate.app/tournament/$id',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                t['name'] ?? 'Tournament',
                style: TextStyle(
                  color: context.isDark ? Colors.white : context.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(t['timeControl'] ?? '').replaceAll('_', ' ')} • ${(t['format'] ?? '').toUpperCase()}',
                style: TextStyle(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (t['isPrivate'] == true && t['inviteCode'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'Code: ${t['inviteCode']}',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: t['inviteCode']));
                          Fluttertoast.showToast(msg: 'Code Copied!', backgroundColor: AppColors.green);
                        },
                        child: const Icon(Icons.copy, color: AppColors.gold, size: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, Map<String, dynamic> t) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '₹${t['prizePool'] ?? 0}',
            valueColor: AppColors.green,
            label: 'Prize Pool',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '₹${t['entryFee'] ?? 0}',
            valueColor: Theme.of(context).colorScheme.primary,
            label: 'Entry Fee',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value:
                '${(t['registeredPlayers'] as List?)?.length ?? 0}/${t['maxPlayers'] ?? 8}',
            valueColor: Colors.blueAccent,
            label: 'Players',
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationProgress(
    BuildContext context,
    Map<String, dynamic> t,
  ) {
    final regCount = (t['registeredPlayers'] as List?)?.length ?? 0;
    final maxCount = t['maxPlayers'] ?? 8;
    final progress = regCount / maxCount;

    DateTime? startTime;
    if (t['startTime'] != null) {
      startTime = DateTime.tryParse(t['startTime'])?.toLocal();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registration Progress',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$regCount / $maxCount',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          if (startTime != null)
            Row(
              children: [
                Icon(Icons.schedule, color: context.textSecondary, size: 16),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Starts at ',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: DateFormat(
                          'MMM d, h:mm a',
                        ).format(startTime.toLocal()),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRules(BuildContext context, Map<String, dynamic> t) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tournament Rules',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleItem(
            context,
            'Format: ${(t['format'] ?? '').toUpperCase()}',
          ),
          _buildRuleItem(
            context,
            'Time control: ${(t['timeControl'] ?? '').replaceAll('_', ' ')}',
          ),
          _buildRuleItem(context, 'Late entry not allowed'),
          _buildRuleItem(
            context,
            'Fair-play monitoring enabled',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(
    BuildContext context,
    String text, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.check, color: AppColors.green, size: 16),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              height: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildRegisteredPlayers(BuildContext context, Map<String, dynamic> t) {
    final players = t['registeredPlayers'] as List? ?? [];
    final playersData = t['registeredPlayersData'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Players',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (players.isEmpty)
          Text(
            'No players registered yet.',
            style: TextStyle(color: context.textSecondary),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: playersData.isNotEmpty 
                ? playersData.take(12).map((p) {
                    final username = p['username']?.toString() ?? 'User';
                    return _PlayerChip(
                      name: username,
                      color: AppColors.purpleLight,
                    );
                  }).toList()
                : players.take(12).map((p) => _PlayerChip(
                      name: p.toString().substring(0, 5),
                      color: AppColors.purpleLight,
                    )).toList(),
          ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    Map<String, dynamic> t,
    bool isLoading,
  ) {
    final bool isRegistered = t['isUserRegistered'] == true;
    final bool isFull = t['isFull'] == true;

    String buttonText = 'Join Tournament';
    if (isRegistered) {
      buttonText = 'Registered';
    } else if (isFull) {
      buttonText = 'Tournament Full';
    }

    final bool isDisabled = isLoading || isRegistered || isFull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        context.read<TournamentBloc>().add(
                          JoinTournament(t['tournamentId']),
                        );
                      },
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isDisabled ? null : AppColors.goldGrad,
                    color: isDisabled ? Colors.grey : AppColors.gold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : Text(
                          buttonText,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(Icons.share, color: context.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final Color valueColor;
  final String label;

  const _StatCard({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String name;
  final Color color;

  const _PlayerChip({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4, left: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
