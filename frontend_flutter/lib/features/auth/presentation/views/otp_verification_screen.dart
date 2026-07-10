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

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
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
        } else if (state is AuthProfileIncomplete) {
          context.go('${AppRoutes.login}/complete-profile');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.surfaceColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          extendBodyBehindAppBar: true,
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
                        Icon(Icons.lock_outline, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Verify OTP', style: TextStyle(color: context.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text('Enter the 6-digit OTP sent to\n${widget.phoneNumber}', textAlign: TextAlign.center, style: TextStyle(color: context.textSecondary, fontSize: 14)),
                        const SizedBox(height: 48),
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassInput(
                                placeholder: '123456',
                                icon: const Icon(Icons.password_outlined),
                                controller: otpController,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 24),
                              if (state is AuthLoading)
                                Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                              else
                                GoldButton(
                                  text: 'Verify',
                                  onTap: () {
                                    context.read<AuthBloc>().add(AuthVerifyOtpRequested(widget.phoneNumber, otpController.text));
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
