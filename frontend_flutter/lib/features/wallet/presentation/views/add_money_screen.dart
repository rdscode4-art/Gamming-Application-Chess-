import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_event.dart';
import '../blocs/wallet_state.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  int _selectedAmount = 500;
  String _selectedMethod = 'UPI';

  final List<int> _amounts = [100, 500, 1000, 5000];

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
                    _buildAmountSection(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildBottomActionBar(),
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
              'Add Money',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Text('Enter Amount', style: TextStyle(color: context.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('₹', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text(
                '$_selectedAmount',
                style: TextStyle(color: context.textPrimary, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani'),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.green, size: 16),
                const SizedBox(width: 8),
                Text('+100% bonus applied!', style: TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT METHOD', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildPaymentOption(context, 'UPI', 'UPI / PhonePe / GPay', 'Instant transfer', Icons.flash_on, Colors.orange),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), height: 1),
          ),
          _buildPaymentOption(context, 'Card', 'Debit / Credit Card', 'Visa, Mastercard, RuPay', Icons.credit_card, Colors.blueAccent),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), height: 1),
          ),
          _buildPaymentOption(context, 'NetBanking', 'Net Banking', 'All major banks', Icons.account_balance, AppColors.purpleLight),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String id, String title, String subtitle, IconData icon, Color iconColor) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? Theme.of(context).colorScheme.primary : context.textSecondary,
            size: 20,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.green, size: 14),
                const SizedBox(width: 6),
                Text('100% Secure • Powered by Razorpay', style: TextStyle(color: context.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: state.isActionLoading
                      ? null
                      : () {
                          context.read<WalletBloc>().add(WalletAddMoney(_selectedAmount));
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: state.isActionLoading ? Colors.grey : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: state.isActionLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).scaffoldBackgroundColor, strokeWidth: 2))
                          : Text('Proceed to Pay ₹$_selectedAmount', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
