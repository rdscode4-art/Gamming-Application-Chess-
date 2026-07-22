import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../../profile/presentation/blocs/profile_state.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int _rewardAmount = 50; // default fallback
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      // Import ApiClient inside the method if not imported globally, or import globally
      final response = await ApiClient.instance.get('/settings/public');
      if (response.data != null && response.data['settings'] != null) {
        if (mounted) {
          setState(() {
            _rewardAmount = (response.data['settings']['referral_reward_amount'] ?? 50) as int;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.isDark ? AppColors.navyGrad : null)),
          const BgBlobs(),
          SafeArea(
            child: Column(
              children: [
                BackHeader(title: 'Refer & Earn', onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroBanner(context),
                        const SizedBox(height: 32),
                        _buildHowItWorks(context),
                        const SizedBox(height: 32),
                        _buildReferralCode(context),
                        const SizedBox(height: 24),
                        _buildShareButton(context),
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
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 80, shadows: [Shadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))])),
          const SizedBox(height: 16),
          Text('Invite Friends\n& Earn Rewards!', textAlign: TextAlign.center, style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', letterSpacing: 1)),
          const SizedBox(height: 8),
          _isLoading 
            ? const CircularProgressIndicator()
            : Text('Get ₹$_rewardAmount for every friend who signs up\nand plays their first match.', textAlign: TextAlign.center, style: TextStyle(color: context.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOW IT WORKS', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            children: [
              _buildStepRow(context, '1', 'Share your link', 'Send your unique referral link to friends.'),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Container(height: 30, width: 2, color: AppColors.gold.withValues(alpha: 0.3), alignment: Alignment.centerLeft),
              ),
              _buildStepRow(context, '2', 'Friend signs up', 'They create an account and deposit.'),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Container(height: 30, width: 2, color: AppColors.gold.withValues(alpha: 0.3), alignment: Alignment.centerLeft),
              ),
              _buildStepRow(context, '3', 'Get rewarded', 'You both get ₹$_rewardAmount in your bonus wallet!'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(BuildContext context, String step, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.gold.withValues(alpha: 0.5))),
          child: Center(child: Text(step, style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: context.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCode(BuildContext context) {
    final state = context.watch<ProfileBloc>().state;
    final code = state.userProfile?['referralCode'] ?? 'CHESS50';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR REFERRAL CODE', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Rajdhani', letterSpacing: 2)),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral code copied!'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.copy, color: AppColors.gold, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    final state = context.watch<ProfileBloc>().state;
    final code = state.userProfile?['referralCode'] ?? 'CHESS50';
    return GestureDetector(
      onTap: () {
        Share.share(
          'Hey! Join Checkmate, the ultimate multiplayer chess platform. '
          'Use my referral code "$code" when signing up to get a joining bonus! '
          'Download now: https://checkmate.app/download'
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.goldGrad,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('Share with Friends', style: TextStyle(color: AppColors.navyDeep, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
