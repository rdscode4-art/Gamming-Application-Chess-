import 'package:equatable/equatable.dart';

abstract class TournamentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTournaments extends TournamentEvent {}

class LoadTournamentDetails extends TournamentEvent {
  final String tournamentId;
  LoadTournamentDetails(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class CreateTournament extends TournamentEvent {
  final Map<String, dynamic> data;
  CreateTournament(this.data);

  @override
  List<Object?> get props => [data];
}

class JoinTournament extends TournamentEvent {
  final String tournamentId;
  JoinTournament(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class JoinTournamentByCode extends TournamentEvent {
  final String inviteCode;
  JoinTournamentByCode(this.inviteCode);

  @override
  List<Object?> get props => [inviteCode];
}

class ClearTournamentMessages extends TournamentEvent {}
