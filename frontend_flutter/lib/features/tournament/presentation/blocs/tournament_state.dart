import 'package:equatable/equatable.dart';

class TournamentState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String? successMessage;
  final List<dynamic> tournaments;
  final Map<String, dynamic>? currentTournament;

  const TournamentState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.successMessage,
    this.tournaments = const [],
    this.currentTournament,
  });

  TournamentState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? successMessage,
    List<dynamic>? tournaments,
    Map<String, dynamic>? currentTournament,
    bool clearMessages = false,
  }) {
    return TournamentState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearMessages ? null : (error ?? this.error),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      tournaments: tournaments ?? this.tournaments,
      currentTournament: currentTournament ?? this.currentTournament,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        error,
        successMessage,
        tournaments,
        currentTournament,
      ];
}
