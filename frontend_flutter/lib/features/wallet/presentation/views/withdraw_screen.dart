import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_event.dart';
import '../blocs/wallet_state.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int? _selectedAmount;
  String _withdrawalMethod = 'UPI';
  final TextEditingController _detailsController = TextEditingController();
  
  final List<int> _amounts = [100, 250, 500, 850];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          Fluttertoast.showToast(
            msg: state.errorMessage!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.red,
            textColor: Colors.white,
          );
          context.read<WalletBloc>().add(WalletClearMessage());
        }
        if (state.successMessage != null) {
          Fluttertoast.showToast(
            msg: state.successMessage!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.green,
            textColor: Colors.white,
          );
          context.read<WalletBloc>().add(WalletClearMessage());
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.bgColor,
        body: SafeArea(
          child: Column(
            children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildAmountInput(),
                    const SizedBox(height: 16),
                    _buildWithdrawalMethod(),
                    const SizedBox(height: 24),
                    _buildKycBanner(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: _buildBottomActionBar(),
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
              'Withdraw',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          borderRadius: 24,
          child: Center(
            child: Column(
              children: [
                Text('Available Balance', style: TextStyle(color: context.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Text('₹${state.winningsBalance}', style: const TextStyle(color: AppColors.green, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani')),
                const SizedBox(height: 8),
                Text('(Winning balance only)', style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInput() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: context.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter amount (Min ₹100)',
                      hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectedAmount = int.tryParse(val);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _amounts.map((amt) {
              final isSelected = _selectedAmount == amt;
              return GestureDetector(
                onTap: () => setState(() => _selectedAmount = amt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '₹$amt',
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).scaffoldBackgroundColor : context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalMethod() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WITHDRAWAL METHOD', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _withdrawalMethod = 'UPI'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _withdrawalMethod == 'UPI' ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flash_on, color: _withdrawalMethod == 'UPI' ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Text('UPI', style: TextStyle(color: _withdrawalMethod == 'UPI' ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _withdrawalMethod = 'Bank'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _withdrawalMethod == 'Bank' ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance, color: _withdrawalMethod == 'Bank' ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Text('Bank', style: TextStyle(color: _withdrawalMethod == 'Bank' ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  _withdrawalMethod == 'UPI' ? Icons.phone_android : Icons.account_balance_wallet,
                  color: context.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _detailsController,
                    style: TextStyle(color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _withdrawalMethod == 'UPI' ? 'Enter UPI ID (e.g. name@okaxis)' : 'Enter Account Number',
                      hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: AppColors.gold, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'KYC verification required for withdrawals above ₹10,000. Processing time: 24-48 hours.',
              style: TextStyle(color: Colors.blueAccent, fontSize: 12, height: 1.4), // Looking closely at the image it's blueish, wait, the screenshot has it somewhat blueish/greyish. Actually looking closer it's a light blue text in a dark gold container.
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.bgColor,
        border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.isActionLoading
                  ? null
                  : () {
                      if (_selectedAmount == null || _detailsController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Please enter amount and payment details',
                          backgroundColor: AppColors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      context.read<WalletBloc>().add(WalletWithdrawMoney(amount: _selectedAmount!, upiId: _detailsController.text));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: state.isActionLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).scaffoldBackgroundColor, strokeWidth: 2))
                  : const Text('Submit Withdrawal Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            );
          },
        ),
      ),
    );
  }
}
