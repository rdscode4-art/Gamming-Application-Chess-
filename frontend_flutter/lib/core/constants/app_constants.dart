class AppConstants {
  // ─── Base URLs ────────────────────────────────────────────────────────────
  // Using production server
  static const String baseUrl = 'https://chessback.ridealdigitalseva.com';
  static const String apiUrl = '$baseUrl/api';

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String tokenKey = 'JWT_ACCESS_TOKEN';
  static const String refreshTokenKey = 'JWT_REFRESH_TOKEN';
  static const String userKey = 'CURRENT_USER';

  // ─── Auth API ─────────────────────────────────────────────────────────────
  static const String guestLoginUrl = '$apiUrl/auth/guest';
  static const String registerUrl = '$apiUrl/auth/register';
  static const String loginUrl = '$apiUrl/auth/login';
  static const String refreshUrl = '$apiUrl/auth/refresh';
  static const String logoutUrl = '$apiUrl/auth/logout';

  // ─── User API ─────────────────────────────────────────────────────────────
  static const String myProfileUrl = '$apiUrl/users/me';
  static const String myGamesUrl = '$apiUrl/users/me/games';
  static String publicProfileUrl(String id) => '$apiUrl/users/$id';

  // ─── Leaderboard API ──────────────────────────────────────────────────────
  static const String leaderboardUrl = '$apiUrl/leaderboard';

  // ─── Contest API (Phase 3) ────────────────────────────────────────────────
  static const String contestModesUrl = '$apiUrl/contests/modes';
  static const String contestQuickJoinUrl = '$apiUrl/contests/quick-join';

  // ─── Wallet API (Phase 4) ─────────────────────────────────────────────────
  static const String walletUrl = '$apiUrl/wallet';
  static const String walletTransactionsUrl = '$apiUrl/wallet/transactions';
  static const String walletDepositUrl = '$apiUrl/wallet/deposit/initiate';
  static const String walletVerifyUrl = '$apiUrl/wallet/deposit/verify';
  static const String walletDepositFailUrl = '$apiUrl/wallet/deposit/fail';
  static const String walletWithdrawUrl = '$apiUrl/wallet/withdraw';

  // ─── Tournament API (Phase 6) ─────────────────────────────────────────────
  static const String tournamentsUrl = '$apiUrl/tournaments';
  static const String tournamentJoinByCodeUrl = '$apiUrl/tournaments/join-by-code';
  static String tournamentDetailUrl(String id) => '$apiUrl/tournaments/$id';
  static String tournamentRegisterUrl(String id) => '$apiUrl/tournaments/$id/register';
  static String tournamentBracketUrl(String id) => '$apiUrl/tournaments/$id/bracket';

  // ─── Notifications API (Phase 7) ──────────────────────────────────────────
  static const String notificationsUrl = '$apiUrl/notifications';
  static const String fcmRegisterUrl = '$apiUrl/notifications/register';

  // ─── Support API (Phase 9) ────────────────────────────────────────────────
  static const String supportTicketsUrl = '$apiUrl/support/tickets';
  static String supportTicketUrl(String id) => '$apiUrl/support/tickets/$id';

  // ─── Socket Events (Outgoing) ─────────────────────────────────────────────
  static const String joinQueue = 'join_queue';
  static const String leaveQueue = 'leave_queue';
  static const String makeMove = 'make_move';
  static const String resign = 'resign';
  static const String reconnectGame = 'rejoin_game';
  static const String offerDraw = 'offer_draw';
  static const String acceptDraw = 'accept_draw';
  static const String declineDraw = 'decline_draw';
  static const String chatMessage = 'chat_message';
  static const String spectateGame = 'spectate_game';

  // ─── Socket Events (Incoming) ─────────────────────────────────────────────
  static const String queueJoined = 'queue_joined';
  static const String matchFound = 'match_found';
  static const String gameState = 'game_state';
  static const String moveAccepted = 'move_accepted';
  static const String invalidMove = 'invalid_move';
  static const String gameOver = 'game_over';
  static const String opponentDisconnected = 'opponent_disconnected';
  static const String opponentReconnected = 'opponent_reconnected';
  static const String clockUpdate = 'clock_update';
  static const String gameResumed = 'game_resumed';
  static const String drawOffered = 'draw_offered';
  static const String drawAccepted = 'draw_accepted';
  static const String drawDeclined = 'draw_declined';
  static const String tournamentMatchReady = 'tournament_match_ready';
  static const String gameInviteReceived = 'game_invite_received';

  // ─── App Config ───────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> timeControls = [
    {'label': '3+0 Rapid', 'key': 'rapid_3', 'minutes': 3, 'increment': 0},
    {'label': '5+0 Rapid', 'key': 'rapid_5', 'minutes': 5, 'increment': 0},
    {'label': '5+3 Rapid', 'key': 'rapid_5_3', 'minutes': 5, 'increment': 3},
    {'label': '10+0 Rapid', 'key': 'rapid_10', 'minutes': 10, 'increment': 0},
    {'label': '15+10 Classic', 'key': 'classic_15', 'minutes': 15, 'increment': 10},
    {'label': '30+0 Classic', 'key': 'classic_30', 'minutes': 30, 'increment': 0},
    {'label': '60+0 Classic', 'key': 'classic_60', 'minutes': 60, 'increment': 0},
  ];

  static const List<int> entryFeeOptions = [0, 10, 25, 50, 100, 500, 1000];
}
