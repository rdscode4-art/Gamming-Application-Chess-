import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameInitData extends GameEvent {
  final Map<String, dynamic> data;
  const GameInitData(this.data);
}

class GameClockTick extends GameEvent {}
class GameDisconnectTick extends GameEvent {}

class GameSocketMoveAccepted extends GameEvent {
  final Map<String, dynamic> data;
  const GameSocketMoveAccepted(this.data);
}

class GameSocketClockUpdate extends GameEvent {
  final Map<String, dynamic> data;
  const GameSocketClockUpdate(this.data);
}

class GameSocketGameOver extends GameEvent {
  final Map<String, dynamic> data;
  const GameSocketGameOver(this.data);
}

class GameSocketOpponentDisconnected extends GameEvent {
  final int timeout;
  const GameSocketOpponentDisconnected(this.timeout);
}

class GameSocketOpponentReconnected extends GameEvent {}

class GameSocketGameState extends GameEvent {
  final Map<String, dynamic> data;
  const GameSocketGameState(this.data);
}

class GameSocketDrawOffered extends GameEvent {
  final String byUserId;
  const GameSocketDrawOffered(this.byUserId);
}

class GameSocketDrawAccepted extends GameEvent {}
class GameSocketDrawDeclined extends GameEvent {}

class GameMakeMove extends GameEvent {
  final String from;
  final String to;
  final String? promotion;
  const GameMakeMove({required this.from, required this.to, this.promotion});
}

class GameResign extends GameEvent {}
class GameOfferDraw extends GameEvent {}
class GameAcceptDraw extends GameEvent {}
class GameDeclineDraw extends GameEvent {}

class GameSendChat extends GameEvent {
  final String message;
  const GameSendChat(this.message);
  @override
  List<Object> get props => [message];
}

class GameSocketChatReceived extends GameEvent {
  final Map<String, dynamic> data;
  const GameSocketChatReceived(this.data);
  @override
  List<Object> get props => [data];
}

class GameClearUnreadMessages extends GameEvent {}
class GameChatOpened extends GameEvent {}
class GameChatClosed extends GameEvent {}
class GameRejoin extends GameEvent {}
class GameClearDrawOffer extends GameEvent {}
