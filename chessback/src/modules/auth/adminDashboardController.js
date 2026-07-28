const User = require('../../models/User');
const Game = require('../../models/Game');
const Transaction = require('../../models/Transaction');
const Tournament = require('../../models/Tournament');
const SupportTicket = require('../../models/SupportTicket');

exports.getDashboardStats = async (req, res) => {
  try {
    // 1. Financial Analytics
    const successfulTransactions = await Transaction.find({ status: 'completed' });
    
    let totalDeposits = 0;
    let totalWithdrawals = 0;
    
    successfulTransactions.forEach(tx => {
      if (tx.type === 'deposit') {
        totalDeposits += tx.amount;
      } else if (tx.type === 'withdrawal') {
        totalWithdrawals += tx.amount;
      }
    });
    
    // Calculate total platform revenue (completed tournaments entry fees - prize pool)
    const completedTournaments = await Tournament.find({ status: 'completed' });
    let totalRevenue = 0;
    completedTournaments.forEach(t => {
      const entryCollected = (t.registeredPlayers ? t.registeredPlayers.length : 0) * (t.entryFee || 0);
      const prizesGiven = t.prizePool || 0;
      if (entryCollected > prizesGiven) {
        totalRevenue += (entryCollected - prizesGiven);
      }
    });

    // 2. User Analytics
    const totalUsers = await User.countDocuments();
    const guestUsers = await User.countDocuments({ isGuest: true });
    const registeredUsers = totalUsers - guestUsers;
    
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const newUsersLast7Days = await User.countDocuments({ createdAt: { $gte: sevenDaysAgo } });

    // 3. Game & Engagement Analytics
    const totalGames = await Game.countDocuments();
    const liveGames = await Game.countDocuments({ status: { $in: ['waiting', 'playing'] } });
    const totalTournaments = await Tournament.countDocuments();

    // 4. Operations
    const pendingTickets = await SupportTicket.countDocuments({ status: 'open' });
    const pendingWithdrawals = await Transaction.countDocuments({ type: 'withdrawal', status: 'pending' });

    res.status(200).json({
      status: 'success',
      data: {
        financials: {
          totalDeposits,
          totalWithdrawals,
          totalRevenue
        },
        users: {
          total: totalUsers,
          guests: guestUsers,
          registered: registeredUsers,
          newLast7Days: newUsersLast7Days
        },
        engagement: {
          totalGames,
          liveGames,
          totalTournaments
        },
        operations: {
          pendingTickets,
          pendingWithdrawals
        }
      }
    });

  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    res.status(500).json({ status: 'error', message: 'Failed to fetch dashboard stats' });
  }
};
