import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final String roomId;
  final String playerColor;
  final String myUserId;
  final String myUsername;
  final int myRating;
  
  final String opponentName;
  final int opponentRating;
  final String opponentUserId;
  final String? opponentAvatarUrl;
  
  final int myTime;
  final int opponentTime;
  final int increment;
  
  final String currentTurn;
  final bool isGameOver;
  final bool isDisconnected;
  final int disconnectCountdown;
  
  final bool drawOfferedByMe;
  final bool drawOfferedByOpponent;
  
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final Map<String, dynamic>? gameResult;
  
  final String timeControlLabel;
  final String contestType;
  final int entryFee;
  final int prizePool;
  
  final String? fen;
  final String? errorMessage;
  final String? successMessage;
  final bool showDrawDialog;
  final List<Map<String, dynamic>> chatMessages;
  final bool hasUnreadMessages;
  final bool isChatOpen;

  bool get isMyTurn => (playerColor == 'white' && currentTurn == 'w') || (playerColor == 'black' && currentTurn == 'b');
  bool get isGameActive => !isGameOver;

  const GameState({
    this.roomId = '',
    this.playerColor = '',
    this.myUserId = '',
    this.myUsername = '',
    this.myRating = 1200,
    this.opponentName = '',
    this.opponentRating = 1200,
    this.opponentUserId = '',
    this.opponentAvatarUrl,
    this.myTime = 600,
    this.opponentTime = 600,
    this.increment = 0,
    this.currentTurn = 'w',
    this.isGameOver = false,
    this.isDisconnected = false,
    this.disconnectCountdown = 60,
    this.drawOfferedByMe = false,
    this.drawOfferedByOpponent = false,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.gameResult,
    this.timeControlLabel = '10+0 Rapid',
    this.contestType = 'casual',
    this.entryFee = 0,
    this.prizePool = 0,
    this.fen,
    this.errorMessage,
    this.successMessage,
    this.showDrawDialog = false,
    this.chatMessages = const [],
    this.hasUnreadMessages = false,
    this.isChatOpen = false,
  });

  GameState copyWith({
    String? roomId,
    String? playerColor,
    String? myUserId,
    String? myUsername,
    int? myRating,
    String? opponentName,
    int? opponentRating,
    String? opponentUserId,
    String? opponentAvatarUrl,
    int? myTime,
    int? opponentTime,
    int? increment,
    String? currentTurn,
    bool? isGameOver,
    bool? isDisconnected,
    int? disconnectCountdown,
    bool? drawOfferedByMe,
    bool? drawOfferedByOpponent,
    String? lastMoveFrom,
    String? lastMoveTo,
    Map<String, dynamic>? gameResult,
    String? timeControlLabel,
    String? contestType,
    int? entryFee,
    int? prizePool,
    String? fen,
    String? errorMessage,
    String? successMessage,
    bool? showDrawDialog,
    List<Map<String, dynamic>>? chatMessages,
    bool? hasUnreadMessages,
    bool? isChatOpen,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      playerColor: playerColor ?? this.playerColor,
      myUserId: myUserId ?? this.myUserId,
      myUsername: myUsername ?? this.myUsername,
      myRating: myRating ?? this.myRating,
      opponentName: opponentName ?? this.opponentName,
      opponentRating: opponentRating ?? this.opponentRating,
      opponentUserId: opponentUserId ?? this.opponentUserId,
      opponentAvatarUrl: opponentAvatarUrl ?? this.opponentAvatarUrl,
      myTime: myTime ?? this.myTime,
      opponentTime: opponentTime ?? this.opponentTime,
      increment: increment ?? this.increment,
      currentTurn: currentTurn ?? this.currentTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      isDisconnected: isDisconnected ?? this.isDisconnected,
      disconnectCountdown: disconnectCountdown ?? this.disconnectCountdown,
      drawOfferedByMe: drawOfferedByMe ?? this.drawOfferedByMe,
      drawOfferedByOpponent: drawOfferedByOpponent ?? this.drawOfferedByOpponent,
      lastMoveFrom: lastMoveFrom ?? this.lastMoveFrom,
      lastMoveTo: lastMoveTo ?? this.lastMoveTo,
      gameResult: gameResult ?? this.gameResult,
      timeControlLabel: timeControlLabel ?? this.timeControlLabel,
      contestType: contestType ?? this.contestType,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      fen: fen ?? this.fen,
      errorMessage: errorMessage, // null intentionally to clear
      successMessage: successMessage, // null intentionally to clear
      showDrawDialog: showDrawDialog ?? this.showDrawDialog,
      chatMessages: chatMessages ?? this.chatMessages,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      isChatOpen: isChatOpen ?? this.isChatOpen,
    );
  }

  @override
  List<Object?> get props => [
    roomId, playerColor,        myUserId,
        myUsername,
        myRating,
        opponentName,
        opponentRating,
    opponentUserId, opponentAvatarUrl, myTime, opponentTime, increment,
    currentTurn, isGameOver, isDisconnected, disconnectCountdown,
    drawOfferedByMe, drawOfferedByOpponent, lastMoveFrom, lastMoveTo,
    gameResult, timeControlLabel,    contestType, entryFee, prizePool, fen, errorMessage, successMessage,
    showDrawDialog, chatMessages, hasUnreadMessages, isChatOpen
  ];
}
