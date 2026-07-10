module.exports = {
  REDIS_KEYS: {
    MATCHMAKING_QUEUE: 'chess:queue:matchmaking',
    MATCHMAKING_LOCK: 'chess:lock:matchmaking',
    ROOM_PREFIX: 'chess:room:',
    USER_SESSION_PREFIX: 'chess:session:',
    DISCONNECT_TIMER_PREFIX: 'chess:disconnect:',
  },

  // All time controls in seconds
  TIME_CONTROLS: {
    rapid_3:    { base: 180,  increment: 0  },
    rapid_5:    { base: 300,  increment: 0  },
    rapid_5_3:  { base: 300,  increment: 3  },
    rapid_10:   { base: 600,  increment: 0  },
    classic_15: { base: 900,  increment: 10 },
    classic_30: { base: 1800, increment: 0  },
    classic_60: { base: 3600, increment: 0  },
  },

  SOCKET_EVENTS: {
    // ── Incoming ──────────────────────────────
    JOIN_QUEUE:     'join_queue',
    LEAVE_QUEUE:    'leave_queue',
    MAKE_MOVE:      'make_move',
    RESIGN:         'resign',
    OFFER_DRAW:     'offer_draw',
    ACCEPT_DRAW:    'accept_draw',
    DECLINE_DRAW:   'decline_draw',
    HEARTBEAT:      'heartbeat',
    REJOIN_GAME:    'rejoin_game',
    CHAT_MESSAGE:   'chat_message',

    // ── Outgoing ──────────────────────────────
    QUEUE_JOINED:            'queue_joined',
    MATCH_FOUND:             'match_found',
    GAME_STATE:              'game_state',
    MOVE_ACCEPTED:           'move_accepted',
    INVALID_MOVE:            'invalid_move',
    GAME_OVER:               'game_over',
    GAME_RESUMED:            'game_resumed',
    OPPONENT_DISCONNECTED:   'opponent_disconnected',
    OPPONENT_RECONNECTED:    'opponent_reconnected',
    CLOCK_UPDATE:            'clock_update',
    DRAW_OFFERED:            'draw_offered',
    DRAW_ACCEPTED:           'draw_accepted',
    DRAW_DECLINED:           'draw_declined',
    ERROR:                   'error',
  },

  DISCONNECT_TIMEOUT: 60, // seconds before auto-forfeit
};
