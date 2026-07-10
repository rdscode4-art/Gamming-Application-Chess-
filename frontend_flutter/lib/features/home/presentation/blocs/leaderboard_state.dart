import 'package:equatable/equatable.dart';

class LeaderboardState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<dynamic> leaderboard;

  const LeaderboardState({
    this.isLoading = false,
    this.error,
    this.leaderboard = const [],
  });

  LeaderboardState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? leaderboard,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, leaderboard];
}
