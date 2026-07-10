const Razorpay = require('razorpay');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const logger = require('../../config/logger');

let razorpayInstance = null;
if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
  razorpayInstance = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
}

// GET /api/wallet
exports.getWalletBalance = async (req, res, next) => {
  try {
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.status(200).json({
      depositBalance: user.depositBalance,
      winningsBalance: user.winningsBalance,
      bonusBalance: user.bonusBalance,
      totalBalance: user.depositBalance + user.winningsBalance + user.bonusBalance,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/wallet/transactions
exports.getTransactionHistory = async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const transactions = await Transaction.find({ userId: req.user.userId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await Transaction.countDocuments({ userId: req.user.userId });

    res.status(200).json({
      transactions,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/wallet/deposit/initiate
exports.createOrder = async (req, res, next) => {
  try {
    const { amount } = req.body; // Amount in INR
    if (!amount || amount < 10) {
      return res.status(400).json({ message: 'Minimum deposit is ₹10' });
    }

    if (!razorpayInstance) {
      return res.status(500).json({ message: 'Razorpay is not configured on the server' });
    }

    const options = {
      amount: amount * 100, // Razorpay uses paise
      currency: 'INR',
      receipt: `receipt_${uuidv4()}`.substring(0, 40),
    };

    const order = await razorpayInstance.orders.create(options);
    
    // Save pending transaction
    await Transaction.create({
      transactionId: uuidv4(),
      userId: req.user.userId,
      type: 'deposit',
      amount: amount,
      balanceType: 'deposit',
      status: 'pending',
      razorpayOrderId: order.id,
      description: `Wallet deposit via Razorpay`,
    });

    res.status(200).json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID, // Send to client to initialize payment
    });
  } catch (error) {
    logger.error(`Razorpay order creation failed: ${error.message}`);
    next(error);
  }
};

// POST /api/wallet/deposit/verify
exports.verifyPayment = async (req, res, next) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ message: 'Missing payment details' });
    }

    // Verify signature
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update(razorpay_order_id + '|' + razorpay_payment_id);
    const expectedSignature = hmac.digest('hex');

    if (expectedSignature !== razorpay_signature) {
      await Transaction.updateOne({ razorpayOrderId: razorpay_order_id }, { status: 'failed' });
      return res.status(400).json({ message: 'Invalid payment signature' });
    }

    // Atomically find transaction and mark completed
    const transaction = await Transaction.findOneAndUpdate(
      { razorpayOrderId: razorpay_order_id, status: 'pending' },
      { status: 'completed', razorpayPaymentId: razorpay_payment_id },
      { new: true }
    );

    if (!transaction) {
      return res.status(400).json({ message: 'Transaction not found or already verified' });
    }

    // Credit user's wallet
    await User.updateOne(
      { userId: req.user.userId },
      { $inc: { depositBalance: transaction.amount } }
    );

    res.status(200).json({ message: 'Payment verified and balance updated successfully' });
  } catch (error) {
    logger.error(`Payment verification failed: ${error.message}`);
    next(error);
  }
};

// POST /api/wallet/deposit/fail
exports.markPaymentFailed = async (req, res, next) => {
  try {
    const { razorpay_order_id } = req.body;
    if (!razorpay_order_id) {
      return res.status(400).json({ message: 'Missing order id' });
    }

    await Transaction.updateOne(
      { razorpayOrderId: razorpay_order_id, status: 'pending' },
      { status: 'failed' }
    );
    res.status(200).json({ message: 'Transaction marked as failed' });
  } catch (error) {
    next(error);
  }
};

// POST /api/wallet/withdraw
exports.requestWithdrawal = async (req, res, next) => {
  try {
    const { amount, paymentDetails } = req.body;
    
    if (!amount || amount < 100) {
      return res.status(400).json({ message: 'Minimum withdrawal is ₹100' });
    }

    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.winningsBalance < amount) {
      return res.status(400).json({ 
        message: 'Insufficient winnings balance',
        winningsBalance: user.winningsBalance 
      });
    }

    // Atomically deduct balance (could use Mongo session in production)
    const updated = await User.findOneAndUpdate(
      { userId: req.user.userId, winningsBalance: { $gte: amount } },
      { $inc: { winningsBalance: -amount } },
      { new: true }
    );

    if (!updated) {
      return res.status(400).json({ message: 'Insufficient winnings balance during deduction' });
    }

    // Create pending withdrawal transaction
    await Transaction.create({
      transactionId: uuidv4(),
      userId: req.user.userId,
      type: 'withdrawal',
      amount: amount,
      balanceType: 'winnings',
      status: 'pending',
      description: `Withdrawal request to ${paymentDetails || 'Default Account'}`,
    });

    res.status(200).json({ 
      message: 'Withdrawal request submitted successfully',
      remainingWinnings: updated.winningsBalance 
    });
  } catch (error) {
    next(error);
  }
};
