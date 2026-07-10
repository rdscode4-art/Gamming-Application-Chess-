import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final Logger _logger = Logger();

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ─────────────────────────────────────────────────────────────
  void connect() {
    if (_socket != null && _socket!.connected) return;

    final token = StorageService.getString(AppConstants.tokenKey);
    if (token == null) {
      _logger.e('Cannot connect socket: no auth token');
      return;
    }

    _reconnectAttempts = 0;

    _socket = IO.io(AppConstants.baseUrl, <String, dynamic>{
      'forceNew': true,
      'transports': ['websocket', 'polling'], // Allow WebSocket directly
      'autoConnect': false,
      'auth': {'token': token},
      'extraHeaders': {'Bypass-Tunnel-Reminder': 'true'},
      'reconnection': true,
      'reconnectionAttempts': _maxReconnectAttempts,
      'reconnectionDelay': 1000,        // 1s
      'reconnectionDelayMax': 10000,    // max 10s
      'timeout': 20000,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _reconnectAttempts = 0;
      _logger.i('✅ Socket Connected: ${AppConstants.baseUrl}');
    });

    _socket!.onDisconnect((reason) {
      _logger.w('⚠️ Socket Disconnected: $reason');
    });

    _socket!.onReconnect((attempt) {
      _logger.i('🔄 Socket Reconnected after $attempt attempt(s)');
    });

    _socket!.onReconnectAttempt((attempt) {
      _logger.w('🔄 Reconnect attempt #$attempt');
    });

    _socket!.onReconnectFailed((_) {
      _logger.e('❌ Reconnect failed after $_maxReconnectAttempts attempts');
    });

    _socket!.onError((err) {
      _logger.e('❌ Socket Error: $err');
    });

    _socket!.on('connect_error', (err) {
      _logger.e('❌ Connection Error: $err');
    });
  }

  // ─── Disconnect ──────────────────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _reconnectAttempts = 0;
    _logger.i('Socket manually disconnected');
  }

  // ─── Force reconnect (call on network restore) ───────────────────────────
  void reconnect() {
    if (_socket != null && !_socket!.connected) {
      _logger.i('Force reconnecting socket...');
      _socket!.connect();
    } else if (_socket == null) {
      connect();
    }
  }

  // ─── Emit ─────────────────────────────────────────────────────────────────
  void emit(String event, [dynamic data]) {
    if (_socket == null || !_socket!.connected) {
      _logger.w('Cannot emit "$event" — socket not connected');
      return;
    }
    _socket!.emit(event, data);
  }

  // ─── Listen ───────────────────────────────────────────────────────────────
  void listen(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  // ─── Remove listener ─────────────────────────────────────────────────────
  void off(String event) {
    _socket?.off(event);
  }

  // ─── Remove all listeners (useful on logout) ─────────────────────────────
  void offAll() {
    _socket?.clearListeners();
  }
}
