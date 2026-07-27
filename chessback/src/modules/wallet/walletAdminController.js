const Transaction = require('../../models/Transaction');
const User = require('../../models/User');
const logger = require('../../config/logger');

// GET /api/admin/withdrawals
exports.getWithdrawals = async (req, res, next) => {
  try {
    const withdrawals = await Transaction.aggregate([
      { $match: { type: 'withdrawal' } },
      { $lookup: { from: 'users', localField: 'userId', foreignField: 'userId', as: 'user' } },
      { $unwind: { path: '$user', preserveNullAndEmptyArrays: true } },
      { $sort: { createdAt: -1 } },
      {
        $project: {
          _id: 1,
          transactionId: 1,
          userId: 1,
          amount: 1,
          status: 1,
          description: 1,
          createdAt: 1,
          'user.username': 1,
          'user.phone': 1,
        }
      }
    ]);
    res.status(200).json(withdrawals);
  } catch (error) {
    logger.error(`Admin get withdrawals failed: ${error.message}`);
    next(error);
  }
};

// PUT /api/admin/withdrawals/:id
exports.updateWithdrawalStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['completed', 'failed'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const transaction = await Transaction.findById(id);
    if (!transaction) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    if (transaction.status !== 'pending') {
      return res.status(400).json({ message: 'Transaction is already processed' });
    }

    if (status === 'completed') {
      transaction.status = 'completed';
      await transaction.save();
    } else if (status === 'failed') {
      // Refund user
      transaction.status = 'failed';
      await transaction.save();

      await User.updateOne(
        { userId: transaction.userId },
        { $inc: { winningsBalance: transaction.amount } }
      );
      logger.info(`Refunded ₹${transaction.amount} to user ${transaction.userId} for failed withdrawal.`);
    }

    res.status(200).json({ message: `Withdrawal marked as ${status}` });
  } catch (error) {
    logger.error(`Admin update withdrawal failed: ${error.message}`);
    next(error);
  }
};
