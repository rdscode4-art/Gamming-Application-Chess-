import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? userProfile;
  final List<dynamic>? matchHistory;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.userProfile,
    this.matchHistory,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userProfile,
    List<dynamic>? matchHistory,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userProfile: userProfile ?? this.userProfile,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, userProfile, matchHistory];
}
