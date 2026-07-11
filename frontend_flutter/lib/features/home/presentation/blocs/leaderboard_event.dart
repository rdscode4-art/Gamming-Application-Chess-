import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final int limit;
  final String type;
  LoadLeaderboard({this.limit = 100, this.type = 'global'});

  @override
  List<Object?> get props => [limit, type];
}
