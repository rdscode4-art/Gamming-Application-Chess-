const User = require('../../models/User');

exports.getUsers = async (req, res, next) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });
    res.json(users);
  } catch (error) { next(error); }
};

exports.updateUserWallet = async (req, res, next) => {
  try {
    const { depositBalance, winningsBalance, bonusBalance } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (depositBalance !== undefined) user.depositBalance = depositBalance;
    if (winningsBalance !== undefined) user.winningsBalance = winningsBalance;
    if (bonusBalance !== undefined) user.bonusBalance = bonusBalance;

    await user.save();
    res.json(user);
  } catch (error) { next(error); }
};

exports.toggleBan = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.isBanned = !user.isBanned;
    await user.save();
    res.json(user);
  } catch (error) { next(error); }
};
