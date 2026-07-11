import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/profile_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _getPref(BuildContext context, String key, bool defaultValue) {
    final state = context.watch<ProfileBloc>().state;
    final prefs = state.userProfile?['preferences'];
    if (prefs != null && prefs[key] != null) return prefs[key];
    return defaultValue;
  }

  void _updatePref(BuildContext context, String key, bool value) {
    context.read<ProfileBloc>().add(UpdatePreferences({key: value}));
  }

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
              _buildSoundSection(context),
              const SizedBox(height: 24),
              _buildPreferencesSection(context),
              const SizedBox(height: 24),
              _buildLegalSection(context),
              const SizedBox(height: 24),
              _buildSupportSection(context),
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
              _buildListTile(
                context, 
                Icons.person_outline, 
                'Edit Profile', 
                true, 
                onTap: () => context.push(AppRoutes.editProfile),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SOUND & HAPTICS', style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
              _buildSwitchTile(context, Icons.volume_up_outlined, 'Game Sounds', _getPref(context, 'gameSounds', true), (val) => _updatePref(context, 'gameSounds', val)),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildSwitchTile(context, Icons.vibration_outlined, 'Move Vibration', _getPref(context, 'moveVibration', true), (val) => _updatePref(context, 'moveVibration', val)),
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
              _buildListTile(context, Icons.description_outlined, 'Terms & Conditions', true, onTap: () => _navigateToLegal(context, 'Terms & Conditions', 'terms_conditions')),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', true, onTap: () => _navigateToLegal(context, 'Privacy Policy', 'privacy_policy')),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(context, Icons.info_outline, 'Responsible Gaming', true, onTap: () => _navigateToLegal(context, 'Responsible Gaming', 'responsible_gaming')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUPPORT & ACCOUNT', style: TextStyle(color: theme.textTheme.labelMedium?.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
              _buildListTile(
                context, 
                Icons.support_agent_outlined, 
                'Help & Support', 
                true, 
                onTap: () => context.push(AppRoutes.support),
              ),
              Divider(color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.2), height: 1, indent: 48),
              _buildListTile(
                context, 
                Icons.delete_outline, 
                'Delete Account', 
                true, 
                onTap: () {
                  _showDeleteAccountDialog(context);
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isDeleting = false;

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Delete Account', style: TextStyle(color: AppColors.red)),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    
    try {
      // Import ApiClient globally or use full path if needed
      // Assuming ApiClient is already imported or available via core/network
      // We will add the import at the top
      await ApiClient.instance.delete('/users/me');
      
      if (mounted) {
        setState(() => _isDeleting = false);
        // Dispatch logout to clear local state
        context.read<AuthBloc>().add(AuthLogoutRequested());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
      }
    }
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

  void _navigateToLegal(BuildContext context, String title, String settingKey) {
    context.push(
      AppRoutes.legal,
      extra: {
        'title': title,
        'settingKey': settingKey,
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
