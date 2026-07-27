import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../routes/app_router.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.bgColor,
          body: Stack(
            children: [
              Container(decoration: BoxDecoration(gradient: context.isDark ? AppColors.navyGrad : null)),
              const BgBlobs(),
              SafeArea(
                child: Column(
                  children: [
                    BackHeader(title: 'My Wallet', onBack: () => context.go(AppRoutes.home)),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 100),
                        child: Column(
                          children: [
                            _buildBalances(context, state),
                            const SizedBox(height: 24),
                            _buildActionButtons(context),
                            const SizedBox(height: 16),
                            _buildPromoBanner(context),
                            const SizedBox(height: 24),
                            _buildRecentTransactions(context, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalances(BuildContext context, WalletState state) {
    final balances = [
      {'label': 'Total Balance', 'val': '₹${state.totalBalance}', 'icon': '💰', 'color': AppColors.gold},
      {'label': 'Winnings', 'val': '₹${state.winningsBalance}', 'icon': '🏆', 'color': AppColors.green},
      {'label': 'Bonus', 'val': '₹${state.bonusBalance}', 'icon': '🎁', 'color': AppColors.purpleLight},
    ];

    return Column(
      children: balances.map((b) {
        final color = b['color'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Center(child: Text(b['icon'] as String, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Text(b['label'] as String, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(
                  b['val'] as String,
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.addMoney),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(24)),
              child: Center(child: Text('Deposit', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.withdraw),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.purpleLight : context.textSecondary, borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.transactions),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
              child: Center(child: Text('History', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green.withValues(alpha: 0.2), AppColors.green.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('First Deposit Bonus', style: TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Get 100% bonus on your first deposit up to ₹500', style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WalletState state) {
    if (state.isTransactionsLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }
    
    final recentTxns = state.transactions.take(4).toList();

    if (recentTxns.isEmpty) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text('No transactions yet.', style: TextStyle(color: context.textSecondary)),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => context.push(AppRoutes.transactions),
              child: Text('View All', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recentTxns.map((t) {
            final isCredit = t['type'] == 'deposit' || t['type'] == 'winnings' || t['type'] == 'prize';
            final isFailed = t['status'] == 'failed';
            final isPending = t['status'] == 'pending';
            final amount = t['amount'] ?? 0;
            final prefix = isCredit ? '+' : '-';
            
            // Format date if possible, otherwise use raw string
            String dateStr = t['createdAt'] ?? '';
            try {
              if (dateStr.isNotEmpty) {
                final d = DateTime.parse(dateStr).toLocal();
                dateStr = '${d.day}/${d.month}/${d.year}';
              }
            } catch (_) {}

            Color statusColor = isFailed ? Colors.grey : (isPending ? Theme.of(context).colorScheme.primary : (isCredit ? AppColors.green : AppColors.red));
            IconData iconData = isFailed ? Icons.close : (isPending ? Icons.access_time : (isCredit ? Icons.call_received : Icons.call_made));

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: statusColor, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(t['description'] ?? 'Transaction', style: TextStyle(color: isFailed ? context.textSecondary : context.textPrimary, fontSize: 12, fontWeight: FontWeight.w600, decoration: isFailed ? TextDecoration.lineThrough : null), overflow: TextOverflow.ellipsis)),
                              if (isFailed || isPending)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(color: (isFailed ? Colors.grey : Theme.of(context).colorScheme.primary).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                    child: Text(isFailed ? 'FAILED' : 'PENDING', style: TextStyle(color: isFailed ? Colors.grey : Theme.of(context).colorScheme.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                          Text(dateStr, style: TextStyle(color: context.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$prefix₹$amount',
                      style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.bold, decoration: isFailed ? TextDecoration.lineThrough : null),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
