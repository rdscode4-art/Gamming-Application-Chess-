import 'package:flutter_bloc/flutter_bloc.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';
import '../../data/repositories/leaderboard_repository.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _repository;

  LeaderboardBloc(this._repository) : super(const LeaderboardState()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboard event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _repository.fetchLeaderboard(limit: event.limit, type: event.type);
      emit(state.copyWith(
        isLoading: false,
        leaderboard: data,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
