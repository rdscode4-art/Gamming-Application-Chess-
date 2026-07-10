import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildAccountSection(context),
              const SizedBox(height: 24),
              _buildPreferencesSection(context),
              const SizedBox(height: 24),
              _buildLegalSection(context),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Checkmate v1.0.0 • Build 2024.12',
                  style: TextStyle(color: Theme.of(context).textTheme.labelMedium?.color, fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: theme.textTheme.displaySmall,
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACCOUNT', style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2)),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildListTile(context, Icons.person_outline, 'Edit Profile', true, onTap: () {}),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.shield_outlined, 'KYC Verification', true, badge: 'PENDING', onTap: () {}),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.lock_outline, 'Change Password', true, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PREFERENCES', style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2)),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildSwitchTile(context, Icons.nightlight_outlined, 'Dark Mode', context.watch<ThemeCubit>().state == ThemeMode.dark, (val) {
                context.read<ThemeCubit>().setDarkTheme(val);
              }),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.grid_on, 'Board Theme', false, trailingText: 'Classic', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LEGAL', style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2)),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildListTile(context, Icons.description_outlined, 'Terms & Conditions', true, onTap: () => _navigateToLegal(context, 'Terms & Conditions')),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', true, onTap: () => _navigateToLegal(context, 'Privacy Policy')),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.info_outline, 'Responsible Gaming', true, onTap: () => _navigateToLegal(context, 'Responsible Gaming')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, bool hasArrow, {String? badge, String? trailingText, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: theme.textTheme.labelMedium?.color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge, style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            if (trailingText != null)
              Text(trailingText, style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 13)),
            if (hasArrow && trailingText == null && badge == null)
              Icon(Icons.chevron_right, color: theme.textTheme.labelMedium?.color, size: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToLegal(BuildContext context, String title) {
    context.push(
      AppRoutes.legal,
      extra: {
        'title': title,
        'content': 'This is the official $title for Checkmate. Please read these terms carefully before using the application. By accessing or using our services, you agree to be bound by these terms.\n\n'
                   '1. Introduction\nWelcome to Checkmate. This application provides a platform for playing chess matches and tournaments.\n\n'
                   '2. User Accounts\nYou are responsible for safeguarding your account password and any activities under your account.\n\n'
                   '3. Code of Conduct\nPlayers must maintain good sportsmanship. Cheating, using engine assistance, or abusing other players will result in immediate ban.\n\n'
                   '4. Financial Transactions\nAll transactions are final. Withdrawals are processed according to our payout schedule.\n\n'
                   '5. Limitation of Liability\nWe are not liable for any indirect, incidental, or consequential damages arising from your use of the app.',
      },
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.textTheme.labelMedium?.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: AppColors.red, size: 20),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
