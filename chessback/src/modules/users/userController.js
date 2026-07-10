const User = require('../../models/User');
const Game = require('../../models/Game');
const { v4: uuidv4 } = require('uuid');

// GET /api/users/me — current user full profile
exports.getMyProfile = async (req, res, next) => {
  try {
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const totalGames = user.wins + user.losses + user.draws;
    const winRate = totalGames > 0 ? ((user.wins / totalGames) * 100).toFixed(1) : 0;

    res.status(200).json({
      userId: user.userId,
      playerId: user.playerId,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isGuest: user.isGuest,
      isKycVerified: user.isKycVerified,
      isBanned: user.isBanned,

      // Ratings
      rating: user.rating,
      classicRating: user.classicRating,
      rapidRating: user.rapidRating,
      ratingHistory: user.ratingHistory,

      // Stats
      wins: user.wins,
      losses: user.losses,
      draws: user.draws,
      totalGames,
      winRate: parseFloat(winRate),

      // Wallet
      depositBalance: user.depositBalance,
      winningsBalance: user.winningsBalance,
      bonusBalance: user.bonusBalance,
      totalBalance: user.depositBalance + user.winningsBalance + user.bonusBalance,

      // Social
      referralCode: user.referralCode,
      referralCount: user.referralCount,

      joinedAt: user.createdAt,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me — update profile
exports.updateMyProfile = async (req, res, next) => {
  try {
    const { username, avatarUrl } = req.body;
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (username && username !== user.username) {
      if (username.length < 3 || username.length > 20) {
        return res.status(400).json({ message: 'Username must be 3-20 characters' });
      }
      const existing = await User.findOne({ username });
      if (existing) return res.status(400).json({ message: 'Username already taken' });
      user.username = username;
    }

    if (avatarUrl !== undefined) user.avatarUrl = avatarUrl;

    await user.save();
    res.status(200).json({ message: 'Profile updated', username: user.username, avatarUrl: user.avatarUrl });
  } catch (error) {
    next(error);
  }
};

// GET /api/users/:id — public profile
exports.getPublicProfile = async (req, res, next) => {
  try {
    const { id } = req.params;
    // Support lookup by userId OR playerId
    const user = await User.findOne({ $or: [{ userId: id }, { playerId: id }] });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const totalGames = user.wins + user.losses + user.draws;
    const winRate = totalGames > 0 ? ((user.wins / totalGames) * 100).toFixed(1) : 0;

    res.status(200).json({
      userId: user.userId,
      playerId: user.playerId,
      username: user.username,
      avatarUrl: user.avatarUrl,
      rating: user.rating,
      classicRating: user.classicRating,
      rapidRating: user.rapidRating,
      wins: user.wins,
      losses: user.losses,
      draws: user.draws,
      totalGames,
      winRate: parseFloat(winRate),
      joinedAt: user.createdAt,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/users/me/games — match history
exports.getMatchHistory = async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const userId = req.user.userId;

    const user = await User.findOne({ userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const games = await Game.find({
      $or: [{ whitePlayer: user._id }, { blackPlayer: user._id }],
      status: 'completed'
    })
      .sort({ endedAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .populate('whitePlayer', 'userId username avatarUrl')
      .populate('blackPlayer', 'userId username avatarUrl');

    const total = await Game.countDocuments({
      $or: [{ whitePlayer: user._id }, { blackPlayer: user._id }],
      status: 'completed'
    });

    const formattedGames = games.map(game => {
      const isWhite = game.whitePlayer.userId === userId;
      const myColor = isWhite ? 'white' : 'black';
      const opponentData = isWhite ? game.blackPlayer : game.whitePlayer;

      let result = 'draw';
      if (game.winner === myColor) result = 'win';
      else if (game.winner && game.winner !== 'draw') result = 'loss';

      return {
        gameId: game.gameId,
        opponent: {
          userId: opponentData.userId,
          username: opponentData.username,
          avatarUrl: opponentData.avatarUrl,
        },
        myColor,
        result,
        reason: game.reason,
        timeControl: game.timeControl,
        contestType: game.contestType,
        ratingBefore: isWhite ? game.whiteRatingBefore : game.blackRatingBefore,
        ratingAfter: isWhite ? game.whiteRatingAfter : game.blackRatingAfter,
        entryFee: game.entryFee,
        prizePool: game.prizePool,
        movesCount: game.moves?.length || 0,
        startedAt: game.startedAt,
        endedAt: game.endedAt,
      };
    });

    res.status(200).json({
      games: formattedGames,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / parseInt(limit)),
      }
    });
  } catch (error) {
    next(error);
  }
};
