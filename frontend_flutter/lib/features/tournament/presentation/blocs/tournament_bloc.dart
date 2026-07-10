import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournament_event.dart';
import 'tournament_state.dart';
import '../../data/repositories/tournament_repository.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _repository;

  TournamentBloc(this._repository) : super(const TournamentState()) {
    on<LoadTournaments>(_onLoadTournaments);
    on<LoadTournamentDetails>(_onLoadTournamentDetails);
    on<CreateTournament>(_onCreateTournament);
    on<JoinTournament>(_onJoinTournament);
    on<ClearTournamentMessages>(_onClearMessages);
  }

  Future<void> _onLoadTournaments(LoadTournaments event, Emitter<TournamentState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final list = await _repository.fetchTournaments();
      emit(state.copyWith(isLoading: false, tournaments: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadTournamentDetails(LoadTournamentDetails event, Emitter<TournamentState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final details = await _repository.fetchTournamentDetails(event.tournamentId);
      emit(state.copyWith(isLoading: false, currentTournament: details));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateTournament(CreateTournament event, Emitter<TournamentState> emit) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repository.createTournament(event.data);
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Tournament created successfully',
      ));
      add(LoadTournaments());
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, error: e.toString()));
    }
  }

  Future<void> _onJoinTournament(JoinTournament event, Emitter<TournamentState> emit) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repository.registerForTournament(event.tournamentId);
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Successfully joined tournament!',
      ));
      add(LoadTournamentDetails(event.tournamentId));
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onClearMessages(ClearTournamentMessages event, Emitter<TournamentState> emit) {
    emit(state.copyWith(clearMessages: true));
  }
}
