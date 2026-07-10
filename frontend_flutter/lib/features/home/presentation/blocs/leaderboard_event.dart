import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final int limit;
  LoadLeaderboard({this.limit = 100});

  @override
  List<Object?> get props => [limit];
}
