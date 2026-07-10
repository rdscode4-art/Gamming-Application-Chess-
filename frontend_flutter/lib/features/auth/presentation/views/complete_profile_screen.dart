import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_input.dart';
import '../../../../core/widgets/primary_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import 'dart:async';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  Timer? _debounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final text = usernameController.text.trim();
    if (text.length < 3) {
      setState(() {
        _isUsernameAvailable = null;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
    });

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final res = await ApiService.post('${AppConstants.apiUrl}/auth/check-username', {
          'username': text,
        });
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = res?['available'] ?? false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    usernameController.removeListener(_onUsernameChanged);
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.surfaceColor,
          body: Stack(
            children: [
              if (context.isDark) const BgBlobs(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Complete Profile', style: TextStyle(color: context.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text('Choose a unique username to start playing', textAlign: TextAlign.center, style: TextStyle(color: context.textSecondary, fontSize: 14)),
                        const SizedBox(height: 48),
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassInput(
                                placeholder: 'Full Name',
                                icon: const Icon(Icons.badge_outlined),
                                controller: fullNameController,
                              ),
                              const SizedBox(height: 16),
                              GlassInput(
                                placeholder: 'Username',
                                icon: const Icon(Icons.person_outline),
                                controller: usernameController,
                                suffixIcon: _buildUsernameSuffix(),
                              ),
                              const SizedBox(height: 16),
                              GlassInput(
                                placeholder: 'Email (Optional)',
                                icon: const Icon(Icons.email_outlined),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              GlassInput(
                                placeholder: 'Referral Code (Optional)',
                                icon: const Icon(Icons.card_giftcard_outlined),
                                controller: referralController,
                              ),
                              const SizedBox(height: 24),
                              if (state is AuthLoading)
                                Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                              else
                                GoldButton(
                                  text: 'Continue',
                                  onTap: () {
                                    context.read<AuthBloc>().add(AuthCompleteProfileRequested(
                                      username: usernameController.text,
                                      email: emailController.text,
                                      fullName: fullNameController.text,
                                      referralCode: referralController.text,
                                    ));
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildUsernameSuffix() {
    if (_isCheckingUsername) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
      );
    }
    if (_isUsernameAvailable == true) {
      return const Icon(Icons.check_circle, color: AppColors.green, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.cancel, color: AppColors.red, size: 20);
    }
    return null;
  }
}
