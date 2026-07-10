import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckTokenRequested>(_onCheckToken);
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthCompleteProfileRequested>(_onCompleteProfile);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await StorageService.clear();
    SocketService().disconnect();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckToken(AuthCheckTokenRequested event, Emitter<AuthState> emit) async {
    final token = StorageService.getString(AppConstants.tokenKey);
    final isProfileComplete = StorageService.getBool('IS_PROFILE_COMPLETE') ?? false;

    if (token != null) {
      if (isProfileComplete) {
        SocketService().connect();
        emit(AuthAuthenticated());
      } else {
        emit(AuthProfileIncomplete());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(AuthSendOtpRequested event, Emitter<AuthState> emit) async {
    if (event.phoneNumber.trim().length < 10) {
      emit(const AuthError('Please enter a valid phone number'));
      return;
    }

    emit(AuthLoading());
    try {
      await ApiService.post('${AppConstants.apiUrl}/auth/request-otp', {
        'phoneNumber': event.phoneNumber.trim(),
      });
      emit(AuthOtpSent(event.phoneNumber.trim()));
    } catch (e) {
      // If error contains "Exception: ", clean it up.
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpRequested event, Emitter<AuthState> emit) async {
    if (event.otp.trim().length < 6) {
      emit(const AuthError('OTP must be 6 digits'));
      return;
    }

    emit(AuthLoading());
    try {
      final res = await ApiService.post('${AppConstants.apiUrl}/auth/verify-otp', {
        'phoneNumber': event.phoneNumber,
        'otp': event.otp.trim(),
      });

      final accessToken = res?['accessToken'];
      final user = res?['user'];

      if (accessToken != null && user != null) {
        await StorageService.setString(AppConstants.tokenKey, accessToken);
        await StorageService.setString('USERNAME', user['username']);
        await StorageService.setString('USER_ID', user['userId'] ?? '');
        await StorageService.setBool('IS_PROFILE_COMPLETE', user['isProfileComplete'] ?? false);
        
        if (user['isProfileComplete'] == true) {
          SocketService().connect();
          emit(AuthAuthenticated());
        } else {
          emit(AuthProfileIncomplete());
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onCompleteProfile(AuthCompleteProfileRequested event, Emitter<AuthState> emit) async {
    if (event.username.trim().length < 3) {
      emit(const AuthError('Username must be at least 3 characters'));
      return;
    }

    emit(AuthLoading());
    try {
      final res = await ApiService.post('${AppConstants.apiUrl}/auth/complete-profile', {
        'username': event.username.trim(),
        'email': event.email.trim(),
        'fullName': event.fullName.trim(),
        'referralCode': event.referralCode.trim(),
      });

      final accessToken = res?['accessToken'];
      final user = res?['user'];

      if (accessToken != null && user != null) {
        await StorageService.setString(AppConstants.tokenKey, accessToken);
        await StorageService.setString('USERNAME', user['username']);
        await StorageService.setString('USER_ID', user['userId'] ?? '');
        await StorageService.setBool('IS_PROFILE_COMPLETE', true);
        
        SocketService().connect();
        emit(AuthAuthenticated());
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }
}
