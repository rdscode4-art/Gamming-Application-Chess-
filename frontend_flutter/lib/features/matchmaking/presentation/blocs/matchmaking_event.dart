import 'package:equatable/equatable.dart';
import '../../domain/models/game_mode.dart';

abstract class MatchmakingEvent extends Equatable {
  const MatchmakingEvent();
  @override
  List<Object?> get props => [];
}

class MatchmakingLoadModes extends MatchmakingEvent {}

class MatchmakingTabChanged extends MatchmakingEvent {
  final int index;
  const MatchmakingTabChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class MatchmakingModeSelected extends MatchmakingEvent {
  final GameMode mode;
  const MatchmakingModeSelected(this.mode);
  @override
  List<Object?> get props => [mode];
}

class MatchmakingPlayRequested extends MatchmakingEvent {}

class MatchmakingSearchCancelled extends MatchmakingEvent {}

class MatchmakingSearchTick extends MatchmakingEvent {}

class MatchmakingQueueJoined extends MatchmakingEvent {}

class MatchmakingMatchFound extends MatchmakingEvent {
  final Map<String, dynamic> matchData;
  const MatchmakingMatchFound(this.matchData);
  @override
  List<Object?> get props => [matchData];
}
