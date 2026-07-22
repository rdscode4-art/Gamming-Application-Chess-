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

      preferences: user.preferences,

      joinedAt: user.createdAt,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me — update profile
exports.updateMyProfile = async (req, res, next) => {
  try {
    const { username, avatarUrl, preferences } = req.body;
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
    
    if (preferences !== undefined) {
      user.preferences = { ...user.preferences, ...preferences };
    }

    await user.save();
    res.status(200).json({ message: 'Profile updated', username: user.username, avatarUrl: user.avatarUrl, preferences: user.preferences });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/users/me — delete profile
exports.deleteMyAccount = async (req, res, next) => {
  try {
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Hard delete for now, as requested.
    await User.deleteOne({ userId: req.user.userId });

    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (error) {
    next(error);
  }
};

// POST /api/users/avatar
exports.uploadAvatar = async (req, res, next) => {
  console.log('[UPLOAD] /api/users/avatar hit. file:', req.file);
  try {
    if (!req.file) {
      console.log('[UPLOAD] No file found in req');
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Assuming the server is running on localhost or a domain, construct the full URL.
    // In production, this should ideally use an env variable for the base URL.
    const baseUrl = process.env.API_BASE_URL || `${req.protocol}://${req.get('host')}`;
    const avatarUrl = `${baseUrl}/avatars/${req.file.filename}`;

    user.avatarUrl = avatarUrl;
    await user.save();

    res.status(200).json({
      message: 'Avatar uploaded successfully',
      avatarUrl: avatarUrl
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/users/fcm-token
exports.updateFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) return res.status(400).json({ message: 'FCM token is required' });

    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (!user.fcmTokens.includes(token)) {
      user.fcmTokens.push(token);
      await user.save();
    }

    res.status(200).json({ message: 'FCM token updated successfully' });
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
