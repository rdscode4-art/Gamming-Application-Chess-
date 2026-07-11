const User = require('../../models/User');

exports.getLeaderboard = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const type = req.query.type || 'global'; // global, classic, rapid

    let sortField = 'rating';
    if (type === 'classic') sortField = 'classicRating';
    if (type === 'rapid') sortField = 'rapidRating';

    const users = await User.find()
      .sort({ [sortField]: -1 })
      .limit(limit)
      .select(`username rating classicRating rapidRating wins losses draws -_id`);

    // Map to generic rating field so frontend doesn't need conditional logic
    const mappedUsers = users.map(u => ({
      username: u.username,
      rating: u[sortField] || u.rating,
      wins: u.wins,
      losses: u.losses,
      draws: u.draws
    }));

    res.status(200).json(mappedUsers);
  } catch (error) {
    next(error);
  }
};
