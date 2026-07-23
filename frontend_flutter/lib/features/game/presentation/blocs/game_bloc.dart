import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SocketService _socket = SocketService();
  Timer? _localTicker;
  Timer? _disconnectTimer;

  GameBloc() : super(const GameState()) {
    on<GameInitData>(_onInitData);
    on<GameClockTick>(_onClockTick);
    on<GameDisconnectTick>(_onDisconnectTick);
    on<GameSocketMoveAccepted>(_onMoveAccepted);
    on<GameSocketClockUpdate>(_onClockUpdate);
    on<GameSocketGameOver>(_onGameOver);
    on<GameSocketOpponentDisconnected>(_onOpponentDisconnected);
    on<GameSocketOpponentReconnected>(_onOpponentReconnected);
    on<GameSocketGameState>(_onGameState);
    on<GameSocketDrawOffered>(_onDrawOffered);
    on<GameSocketDrawAccepted>(_onDrawAccepted);
    on<GameSocketDrawDeclined>(_onDrawDeclined);
    on<GameMakeMove>(_onMakeMove);
    on<GameResign>(_onResign);
    on<GameOfferDraw>(_onOfferDraw);
    on<GameAcceptDraw>(_onAcceptDraw);
    on<GameDeclineDraw>(_onDeclineDraw);
    on<GameSendChat>(_onSendChat);
    on<GameSocketChatReceived>(_onChatReceived);
    on<GameClearUnreadMessages>(_onClearUnreadMessages);
    on<GameChatOpened>(_onChatOpened);
    on<GameChatClosed>(_onChatClosed);
    on<GameRejoin>(_onRejoin);
    on<GameClearDrawOffer>(_onClearDrawOffer);

    _setupSocketListeners();
  }

  void _rejoinGame() {
    add(GameRejoin());
  }

  void _setupSocketListeners() {
    _socket.addConnectListener(_rejoinGame);
    _socket.listen(AppConstants.moveAccepted, (data) => add(GameSocketMoveAccepted(data)));
    _socket.listen(AppConstants.clockUpdate, (data) => add(GameSocketClockUpdate(data)));
    _socket.listen(AppConstants.gameOver, (data) => add(GameSocketGameOver(data)));
    _socket.listen(AppConstants.opponentDisconnected, (data) => add(GameSocketOpponentDisconnected(data['timeout'] ?? 60)));
    _socket.listen(AppConstants.opponentReconnected, (_) => add(GameSocketOpponentReconnected()));
    _socket.listen(AppConstants.gameState, (data) => add(GameSocketGameState(data)));
    _socket.listen(AppConstants.drawOffered, (data) => add(GameSocketDrawOffered(data['byUserId'])));
    _socket.listen(AppConstants.drawAccepted, (_) => add(GameSocketDrawAccepted()));
    _socket.listen(AppConstants.drawDeclined, (_) => add(GameSocketDrawDeclined()));
    _socket.listen(AppConstants.chatMessage, (data) => add(GameSocketChatReceived(data)));
  }

  void _onInitData(GameInitData event, Emitter<GameState> emit) {
    final data = event.data;
    final myUserId = StorageService.getString('USER_ID') ?? '';
    final myUsername = StorageService.getString('USERNAME') ?? '';

    final whitePlayer = data['whitePlayer'];
    final blackPlayer = data['blackPlayer'];
    final bool imWhite = whitePlayer['userId'] == myUserId || whitePlayer['username'] == myUsername;
    final me = imWhite ? whitePlayer : blackPlayer;
    final opponent = imWhite ? blackPlayer : whitePlayer;

    final tc = data['timeControl'] ?? 'rapid_10';
    final tcMap = AppConstants.timeControls.firstWhere((t) => t['key'] == tc, orElse: () => {'label': tc});

    emit(state.copyWith(
      roomId: data['roomId'] ?? '',
      playerColor: imWhite ? 'white' : 'black',
      myUserId: me['userId'] ?? myUserId,
      myUsername: myUsername,
      myRating: (me['rating'] ?? 1200) as int,
      opponentName: opponent['username'] ?? 'Opponent',
      opponentRating: (opponent['rating'] ?? 1200) as int,
      opponentUserId: opponent['userId'] ?? '',
      opponentAvatarUrl: opponent['avatarUrl'],
      myTime: (imWhite ? data['whiteTime'] : data['blackTime']) ?? 600,
      opponentTime: (imWhite ? data['blackTime'] : data['whiteTime']) ?? 600,
      increment: (data['increment'] ?? 0) as int,
      contestType: data['contestType'] ?? 'casual',
      entryFee: (data['entryFee'] ?? 0) as int,
      prizePool: (data['prizePool'] ?? 0) as int,
      timeControlLabel: tcMap['label'] ?? tc,
      fen: data['fen'],
    ));

    _localTicker?.cancel();
    _localTicker = Timer.periodic(const Duration(seconds: 1), (_) => add(GameClockTick()));
    
    // Guarantee socket is in the room
    _socket.emit(AppConstants.reconnectGame);
  }

  void _onClockTick(GameClockTick event, Emitter<GameState> emit) {
    if (state.isGameOver || state.isDisconnected) return;
    if (state.isMyTurn) {
      if (state.myTime > 0) emit(state.copyWith(myTime: state.myTime - 1));
    } else {
      if (state.opponentTime > 0) emit(state.copyWith(opponentTime: state.opponentTime - 1));
    }
  }

  void _onDisconnectTick(GameDisconnectTick event, Emitter<GameState> emit) {
    if (state.disconnectCountdown > 0) {
      emit(state.copyWith(disconnectCountdown: state.disconnectCountdown - 1));
    } else {
      _disconnectTimer?.cancel();
    }
  }

  void _onMoveAccepted(GameSocketMoveAccepted event, Emitter<GameState> emit) {
    final data = event.data;
    final isWhite = state.playerColor == 'white';
    print('📥 GameBloc: Received MOVE_ACCEPTED. new turn: ${data['turn']}, fen: ${data['fen']}');
    emit(state.copyWith(
      fen: data['fen'],
      currentTurn: data['turn'] ?? state.currentTurn,
      lastMoveFrom: data['lastMove']?['from'],
      lastMoveTo: data['lastMove']?['to'],
      myTime: (isWhite ? data['whiteTime'] : data['blackTime']) ?? state.myTime,
      opponentTime: (isWhite ? data['blackTime'] : data['whiteTime']) ?? state.opponentTime,
      drawOfferedByMe: false,
      drawOfferedByOpponent: false,
    ));
  }

  void _onClockUpdate(GameSocketClockUpdate event, Emitter<GameState> emit) {
    final isWhite = state.playerColor == 'white';
    emit(state.copyWith(
      myTime: (isWhite ? event.data['whiteTime'] : event.data['blackTime']) ?? state.myTime,
      opponentTime: (isWhite ? event.data['blackTime'] : event.data['whiteTime']) ?? state.opponentTime,
    ));
  }

  void _onGameOver(GameSocketGameOver event, Emitter<GameState> emit) {
    _localTicker?.cancel();
    emit(state.copyWith(isGameOver: true, gameResult: Map<String, dynamic>.from(event.data)));
  }

  void _onOpponentDisconnected(GameSocketOpponentDisconnected event, Emitter<GameState> emit) {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer.periodic(const Duration(seconds: 1), (_) => add(GameDisconnectTick()));
    emit(state.copyWith(isDisconnected: true, disconnectCountdown: event.timeout));
  }

  void _onOpponentReconnected(GameSocketOpponentReconnected event, Emitter<GameState> emit) {
    _disconnectTimer?.cancel();
    emit(state.copyWith(isDisconnected: false, successMessage: 'Opponent Reconnected! Game continues.'));
  }

  void _onGameState(GameSocketGameState event, Emitter<GameState> emit) {
    final data = event.data;
    final isWhite = state.playerColor == 'white';
    emit(state.copyWith(
      fen: data['fen'],
      currentTurn: data['turn'] ?? state.currentTurn,
      myTime: (isWhite ? data['whiteTime'] : data['blackTime']) ?? state.myTime,
      opponentTime: (isWhite ? data['blackTime'] : data['whiteTime']) ?? state.opponentTime,
      isDisconnected: false,
    ));
  }

  void _onDrawOffered(GameSocketDrawOffered event, Emitter<GameState> emit) {
    if (event.byUserId != state.myUserId) {
      emit(state.copyWith(drawOfferedByOpponent: true, showDrawDialog: true));
    }
  }

  void _onDrawAccepted(GameSocketDrawAccepted event, Emitter<GameState> emit) {
    emit(state.copyWith(drawOfferedByMe: false, drawOfferedByOpponent: false));
  }

  void _onDrawDeclined(GameSocketDrawDeclined event, Emitter<GameState> emit) {
    emit(state.copyWith(drawOfferedByMe: false, errorMessage: 'Opponent declined your draw offer'));
  }

  void _onClearDrawOffer(GameClearDrawOffer event, Emitter<GameState> emit) {
    emit(state.copyWith(showDrawDialog: false));
  }

  void _onMakeMove(GameMakeMove event, Emitter<GameState> emit) {
    print('♟️ GameBloc: _onMakeMove triggered. isMyTurn: ${state.isMyTurn}');
    if (state.isGameOver || state.isDisconnected || !state.isMyTurn) {
      print('🚫 GameBloc: Move ignored. isGameOver: ${state.isGameOver}, isDisconnected: ${state.isDisconnected}, isMyTurn: ${state.isMyTurn}');
      return;
    }
    print('✅ GameBloc: Emitting move to server: ${event.from} -> ${event.to}');
    _socket.emit(AppConstants.makeMove, {
      'roomId': state.roomId,
      'move': {'from': event.from, 'to': event.to, if (event.promotion != null) 'promotion': event.promotion},
    });
  }

  void _onResign(GameResign event, Emitter<GameState> emit) {
    _socket.emit(AppConstants.resign, {'roomId': state.roomId});
  }

  void _onOfferDraw(GameOfferDraw event, Emitter<GameState> emit) {
    if (state.drawOfferedByMe) return;
    emit(state.copyWith(drawOfferedByMe: true, successMessage: 'Draw offered. Waiting for response...'));
    _socket.emit(AppConstants.offerDraw, {'roomId': state.roomId});
  }

  void _onAcceptDraw(GameAcceptDraw event, Emitter<GameState> emit) {
    emit(state.copyWith(drawOfferedByOpponent: false, showDrawDialog: false));
    _socket.emit(AppConstants.acceptDraw, {'roomId': state.roomId});
  }

  void _onDeclineDraw(GameDeclineDraw event, Emitter<GameState> emit) {
    emit(state.copyWith(drawOfferedByOpponent: false, showDrawDialog: false));
    _socket.emit(AppConstants.declineDraw, {'roomId': state.roomId});
  }

  void _onRejoin(GameRejoin event, Emitter<GameState> emit) {
    _socket.emit(AppConstants.reconnectGame, {});
  }

  void _onSendChat(GameSendChat event, Emitter<GameState> emit) {
    if (event.message.trim().isEmpty) return;
    _socket.emit(AppConstants.chatMessage, {
      'roomId': state.roomId,
      'message': event.message.trim(),
    });
    // Add our own message to state locally for instant feedback
    final newMsg = {
      'message': event.message.trim(),
      'byUserId': state.myUserId,
      'byUsername': state.myUsername,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    emit(state.copyWith(chatMessages: List.from(state.chatMessages)..add(newMsg)));
  }

  void _onChatReceived(GameSocketChatReceived event, Emitter<GameState> emit) {
    // Only add if it's from the opponent (we added ours locally)
    if (event.data['byUserId'] != state.myUserId) {
      emit(state.copyWith(
        chatMessages: List.from(state.chatMessages)..add(event.data),
        hasUnreadMessages: !state.isChatOpen, // Only show red dot if chat is not currently open
      ));
    }
  }

  void _onClearUnreadMessages(GameClearUnreadMessages event, Emitter<GameState> emit) {
    emit(state.copyWith(hasUnreadMessages: false));
  }

  void _onChatOpened(GameChatOpened event, Emitter<GameState> emit) {
    emit(state.copyWith(isChatOpen: true, hasUnreadMessages: false));
  }

  void _onChatClosed(GameChatClosed event, Emitter<GameState> emit) {
    emit(state.copyWith(isChatOpen: false));
  }

  @override
  Future<void> close() {
    _socket.removeConnectListener(_rejoinGame);
    _localTicker?.cancel();
    _disconnectTimer?.cancel();
    _socket.off(AppConstants.moveAccepted);
    _socket.off(AppConstants.clockUpdate);
    _socket.off(AppConstants.gameOver);
    _socket.off(AppConstants.opponentDisconnected);
    _socket.off(AppConstants.opponentReconnected);
    _socket.off(AppConstants.gameState);
    _socket.off(AppConstants.drawOffered);
    _socket.off(AppConstants.drawAccepted);
    _socket.off(AppConstants.drawDeclined);
    _socket.off(AppConstants.chatMessage);
    return super.close();
  }
}
