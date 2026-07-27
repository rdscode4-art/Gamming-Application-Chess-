import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournament_event.dart';
import 'tournament_state.dart';
import '../../data/repositories/tournament_repository.dart';
import '../../../../core/di/service_locator.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/blocs/wallet_event.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _repository;

  TournamentBloc(this._repository) : super(const TournamentState()) {
    on<LoadTournaments>(_onLoadTournaments);
    on<LoadTournamentDetails>(_onLoadTournamentDetails);
    on<CreateTournament>(_onCreateTournament);
    on<JoinTournament>(_onJoinTournament);
    on<JoinTournamentByCode>(_onJoinTournamentByCode);
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
      getIt<WalletBloc>().add(WalletFetchData());
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
      getIt<WalletBloc>().add(WalletFetchData());
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onJoinTournamentByCode(JoinTournamentByCode event, Emitter<TournamentState> emit) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      final response = await _repository.joinTournamentByCode(event.inviteCode);
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Successfully joined tournament!',
      ));
      if (response['tournament'] != null) {
        add(LoadTournamentDetails(response['tournament']['tournamentId']));
      }
      getIt<WalletBloc>().add(WalletFetchData());
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onClearMessages(ClearTournamentMessages event, Emitter<TournamentState> emit) {
    emit(state.copyWith(clearMessages: true));
  }
}
