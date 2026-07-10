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

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
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
        if (state is AuthOtpSent) {
          context.push('${AppRoutes.login}/otp', extra: state.phoneNumber);
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
                        Icon(Icons.castle, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Chess Royale', style: TextStyle(color: context.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text('Enter your phone number to continue', style: TextStyle(color: context.textSecondary, fontSize: 14)),
                        const SizedBox(height: 48),
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassInput(
                                placeholder: 'Phone Number',
                                icon: const Icon(Icons.phone_outlined),
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 24),
                              if (state is AuthLoading)
                                Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                              else
                                GoldButton(
                                  text: 'Get OTP',
                                  onTap: () {
                                    context.read<AuthBloc>().add(AuthSendOtpRequested(phoneController.text));
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
}
