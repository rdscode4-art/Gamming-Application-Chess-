import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Deposits', 'Withdrawals', 'Entries', 'Winnings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state.isTransactionsLoading) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }
                  
                  final allTxns = state.transactions;
                  final txns = allTxns.where((t) {
                    if (_selectedTab == 'All') return true;
                    if (_selectedTab == 'Deposits') return t['type'] == 'deposit';
                    if (_selectedTab == 'Withdrawals') return t['type'] == 'withdrawal';
                    if (_selectedTab == 'Entries') return t['type'] == 'entry_fee';
                    if (_selectedTab == 'Winnings') return t['type'] == 'prize' || t['type'] == 'winnings';
                    return true;
                  }).toList();

                  if (txns.isEmpty) {
                    return Center(child: Text('No $_selectedTab transactions found', style: TextStyle(color: context.textSecondary)));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(txns[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
          Expanded(
            child: Text(
              'Transactions',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(dynamic txn) {
    final isCredit = txn['type'] == 'deposit' || txn['type'] == 'winnings' || txn['type'] == 'prize';
    final isFailed = txn['status'] == 'failed';
    final isPending = txn['status'] == 'pending';
    final amount = txn['amount'] ?? 0;
    final prefix = isCredit ? '+' : '-';

    String dateStr = txn['createdAt'] ?? '';
    try {
      if (dateStr.isNotEmpty) {
        final d = DateTime.parse(dateStr).toLocal();
        dateStr = '${d.day}/${d.month}/${d.year}';
      }
    } catch (_) {}

    Color statusColor = isFailed ? Colors.grey : (isPending ? Theme.of(context).colorScheme.primary : (isCredit ? AppColors.green : AppColors.red));
    IconData iconData = isFailed ? Icons.close : (isPending ? Icons.access_time : (isCredit ? Icons.call_received : Icons.call_made));

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: statusColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(txn['description'] ?? 'Transaction', style: TextStyle(color: isFailed ? context.textSecondary : context.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, decoration: isFailed ? TextDecoration.lineThrough : null))),
                    if (isFailed || isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: (isFailed ? Colors.grey : Theme.of(context).colorScheme.primary).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(isFailed ? 'FAILED' : 'PENDING', style: TextStyle(color: isFailed ? Colors.grey : Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$prefix₹$amount',
            style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold, decoration: isFailed ? TextDecoration.lineThrough : null),
          ),
        ],
      ),
    );
  }
}
