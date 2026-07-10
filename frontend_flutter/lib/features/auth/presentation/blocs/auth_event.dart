import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckTokenRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}

class AuthSendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const AuthSendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const AuthVerifyOtpRequested(this.phoneNumber, this.otp);

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthCompleteProfileRequested extends AuthEvent {
  final String username;
  final String email;
  final String fullName;
  final String referralCode;
  
  const AuthCompleteProfileRequested({
    required this.username,
    required this.email,
    required this.fullName,
    required this.referralCode,
  });

  @override
  List<Object?> get props => [username, email, fullName, referralCode];
}
