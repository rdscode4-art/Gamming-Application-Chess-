const User = require('../../models/User');

exports.getLeaderboard = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    
    const users = await User.find()
      .sort({ rating: -1 })
      .limit(limit)
      .select('username rating wins losses draws -_id');

    res.status(200).json(users);
  } catch (error) {
    next(error);
  }
};
