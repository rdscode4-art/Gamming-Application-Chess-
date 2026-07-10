import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'matchmaking_event.dart';
import 'matchmaking_state.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/models/game_mode.dart';
import '../../data/repositories/matchmaking_repository.dart';

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final SocketService _socket = SocketService();
  final MatchmakingRepository _repository;
  Timer? _searchTimer;

  MatchmakingBloc({required MatchmakingRepository repository}) 
      : _repository = repository,
        super(const MatchmakingState()) {
    on<MatchmakingLoadModes>(_onLoadModes);
    on<MatchmakingTabChanged>(_onTabChanged);
    on<MatchmakingModeSelected>(_onModeSelected);
    on<MatchmakingPlayRequested>(_onPlayRequested);
    on<MatchmakingSearchCancelled>(_onSearchCancelled);
    on<MatchmakingSearchTick>(_onSearchTick);
    on<MatchmakingQueueJoined>(_onQueueJoined);
    on<MatchmakingMatchFound>(_onMatchFound);

    _setupListeners();
    add(MatchmakingLoadModes());
  }

  void _setupListeners() {
    _socket.listen(AppConstants.queueJoined, (data) {
      add(MatchmakingQueueJoined());
    });
    _socket.listen(AppConstants.matchFound, (data) {
      add(MatchmakingMatchFound(data));
    });
  }

  Future<void> _onLoadModes(MatchmakingLoadModes event, Emitter<MatchmakingState> emit) async {
    final username = StorageService.getString('USERNAME') ?? '';
    int rating = 1200;
    try {
      final res = await ApiService.get('${AppConstants.apiUrl}/users/me');
      if (res != null && res['rating'] != null) {
        rating = res['rating'] as int;
      }
    } catch (_) {}
    
    emit(state.copyWith(isLoading: true, myUsername: username, myRating: rating));

    try {
      final modesData = await _repository.getGameModes();
      if (modesData.isNotEmpty) {
        final List<GameMode> modes = modesData.map((m) {
          final map = m as Map<String, dynamic>;
          map['isRated'] = true;
          return GameMode.fromJson(map);
        }).toList();
        final List<GameMode> freeModes = modes.where((m) => !m.isPaid).toList();
        final List<GameMode> paidModes = modes.where((m) => m.isPaid).toList();
        
        emit(state.copyWith(
          freeModes: freeModes,
          paidModes: paidModes,
          ratedModes: [],
          selectedMode: freeModes.isNotEmpty ? freeModes[1] : null,
          isLoading: false,
        ));
      } else {
        _loadFallbackModes(emit);
      }
    } catch (e) {
      _loadFallbackModes(emit);
    }
  }

  void _loadFallbackModes(Emitter<MatchmakingState> emit) {
    final free = [
      const GameMode(id: 'free_rapid_3', label: 'Bullet 3+0', timeControl: 'rapid_3', entryFee: 0, prize: 0, isRated: true, tag: 'Free'),
      const GameMode(id: 'free_rapid_5', label: 'Blitz 5+0', timeControl: 'rapid_5', entryFee: 0, prize: 0, isRated: true, tag: 'Free'),
      const GameMode(id: 'free_rapid_10', label: 'Rapid 10+0', timeControl: 'rapid_10', entryFee: 0, prize: 0, isRated: true, tag: 'Free'),
    ];
    final paid = [
      const GameMode(id: 'paid_10', label: '₹10 Match', timeControl: 'rapid_10', entryFee: 10, prize: 18, isRated: true, tag: '₹10'),
      const GameMode(id: 'paid_25', label: '₹25 Match', timeControl: 'rapid_10', entryFee: 25, prize: 45, isRated: true, tag: '₹25'),
    ];
    
    emit(state.copyWith(
      freeModes: free, paidModes: paid, ratedModes: [],
      selectedMode: free.isNotEmpty ? free[1] : null,
      isLoading: false,
    ));
  }

  void _onTabChanged(MatchmakingTabChanged event, Emitter<MatchmakingState> emit) {
    emit(state.copyWith(selectedTab: event.index));
  }

  void _onModeSelected(MatchmakingModeSelected event, Emitter<MatchmakingState> emit) {
    if (!state.isSearching) {
      emit(state.copyWith(selectedMode: event.mode));
    }
  }

  Future<void> _onPlayRequested(MatchmakingPlayRequested event, Emitter<MatchmakingState> emit) async {
    final mode = state.selectedMode;
    if (mode == null) return;
    
    // Clear old match data immediately so MatchmakingScreen doesn't falsely trigger navigation
    emit(state.copyWith(clearMatchData: true));

    if (mode.isPaid) {
      try {
        final resp = await _repository.quickJoin(
          timeControl: mode.timeControl, 
          entryFee: mode.entryFee, 
          isRated: mode.isRated
        );
        if (resp != null) {
          emit(state.copyWith(myBalance: resp['remainingBalance'] ?? state.myBalance));
        }
      } catch (e) {
        emit(state.copyWith(error: 'Failed to join: ${e.toString()}'));
        return;
      }
    }

    if (!_socket.isConnected) {
      print('⏳ Socket is NOT connected. Attempting to connect now...');
      _socket.connect();
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _socket.emit(AppConstants.joinQueue, {
      'timeControl': mode.timeControl,
      'entryFee': mode.entryFee,
      'isRated': mode.isRated,
      'contestType': mode.isPaid ? 'paid' : (mode.isRated ? 'rated' : 'casual'),
    });
  }

  void _onQueueJoined(MatchmakingQueueJoined event, Emitter<MatchmakingState> emit) {
    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (_) => add(MatchmakingSearchTick()));
    emit(state.copyWith(isSearching: true, searchElapsed: 0, clearMatchData: true));
  }

  void _onSearchTick(MatchmakingSearchTick event, Emitter<MatchmakingState> emit) {
    emit(state.copyWith(searchElapsed: state.searchElapsed + 1));
  }

  void _onSearchCancelled(MatchmakingSearchCancelled event, Emitter<MatchmakingState> emit) {
    _socket.emit(AppConstants.leaveQueue, {});
    _searchTimer?.cancel();
    emit(state.copyWith(isSearching: false, searchElapsed: 0, clearMatchData: true));
  }

  void _onMatchFound(MatchmakingMatchFound event, Emitter<MatchmakingState> emit) {
    _searchTimer?.cancel();
    emit(state.copyWith(isSearching: false, matchFoundData: event.matchData));
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _socket.off(AppConstants.queueJoined);
    _socket.off(AppConstants.matchFound);
    return super.close();
  }
}
