const Tournament = require('../../models/Tournament');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const SystemSetting = require('../../models/SystemSetting');
const { v4: uuidv4 } = require('uuid');

// POST /api/tournaments
exports.createTournament = async (req, res, next) => {
  try {
    const { name, description, format, timeControl, maxPlayers, entryFee, startTime, isPrivate, customDistribution = [100] } = req.body;

    const commissionSetting = await SystemSetting.findOne({ key: 'user_private_tournament_commission' });
    const commissionPercentage = commissionSetting && commissionSetting.value !== undefined ? Number(commissionSetting.value) : 10;

    const totalCollection = (entryFee || 0) * (maxPlayers || 8);
    const platformFee = Math.floor(totalCollection * (commissionPercentage / 100));
    const prizePool = totalCollection - platformFee;

    let prizeDistribution = [];
    if (prizePool > 0) {
      customDistribution.forEach((percentage, index) => {
        if (percentage > 0) {
          prizeDistribution.push({
            position: index + 1,
            percentage: percentage,
            amount: Math.floor(prizePool * (percentage / 100))
          });
        }
      });
    }

    const tournament = await Tournament.create({
      tournamentId: uuidv4(),
      name,
      description,
      format,
      timeControl,
      maxPlayers,
      entryFee,
      prizePool,
      platformFee,
      commissionPercentage,
      distributionStrategy: 'custom',
      prizeDistribution,
      startTime,
      isPrivate,
      createdBy: req.user.userId,
      status: 'registration'
    });

    res.status(201).json(tournament);
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments
exports.getTournaments = async (req, res, next) => {
  try {
    const tournaments = await Tournament.find({ isPrivate: false })
      .sort({ startTime: 1 })
      .limit(50);
    res.status(200).json(tournaments);
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments/:id
exports.getTournamentDetails = async (req, res, next) => {
  try {
    const tournament = await Tournament.findOne({ tournamentId: req.params.id });
    if (!tournament) return res.status(404).json({ message: 'Tournament not found' });
    
    const tournamentObj = tournament.toObject();
    tournamentObj.isUserRegistered = tournament.registeredPlayers.includes(req.user.userId);
    tournamentObj.isFull = tournament.registeredPlayers.length >= tournament.maxPlayers;

    // In a real app, we'd populate registered players' details
    res.status(200).json(tournamentObj);
  } catch (error) {
    next(error);
  }
};

// POST /api/tournaments/:id/register
exports.registerForTournament = async (req, res, next) => {
  try {
    const tournament = await Tournament.findOne({ tournamentId: req.params.id });
    if (!tournament) return res.status(404).json({ message: 'Tournament not found' });
    if (tournament.status !== 'registration') return res.status(400).json({ message: 'Registration is closed' });
    
    if (tournament.registeredPlayers.includes(req.user.userId)) {
      return res.status(400).json({ message: 'Already registered' });
    }

    if (tournament.registeredPlayers.length >= tournament.maxPlayers) {
      return res.status(400).json({ message: 'Tournament is full' });
    }

    if (tournament.entryFee > 0) {
      const user = await User.findOne({ userId: req.user.userId });
      const totalBalance = user.depositBalance + user.winningsBalance + user.bonusBalance;
      
      if (totalBalance < tournament.entryFee) {
        return res.status(400).json({ message: 'Insufficient balance' });
      }

      // Deduct fee (simplified atomic logic)
      let feeRemaining = tournament.entryFee;
      let depositDeduct = 0, winningsDeduct = 0, bonusDeduct = 0;

      // 1. Deduct from bonus first (if allowed, usually up to x%)
      // For simplicity, deduct entirely from deposit first, then winnings, then bonus
      if (user.depositBalance >= feeRemaining) {
        depositDeduct = feeRemaining;
        feeRemaining = 0;
      } else {
        depositDeduct = user.depositBalance;
        feeRemaining -= depositDeduct;
      }

      if (feeRemaining > 0) {
        if (user.winningsBalance >= feeRemaining) {
          winningsDeduct = feeRemaining;
          feeRemaining = 0;
        } else {
          winningsDeduct = user.winningsBalance;
          feeRemaining -= winningsDeduct;
        }
      }

      if (feeRemaining > 0) {
        bonusDeduct = feeRemaining;
      }

      await User.updateOne(
        { userId: req.user.userId },
        { 
          $inc: { 
            depositBalance: -depositDeduct,
            winningsBalance: -winningsDeduct,
            bonusBalance: -bonusDeduct
          } 
        }
      );

      await Transaction.create({
        transactionId: uuidv4(),
        userId: req.user.userId,
        type: 'entry_fee',
        amount: tournament.entryFee,
        balanceType: 'mixed',
        status: 'completed',
        description: `Entry fee for tournament ${tournament.name}`,
      });
    }

    tournament.registeredPlayers.push(req.user.userId);
    await tournament.save();

    res.status(200).json({ message: 'Registered successfully', tournament });
  } catch (error) {
    next(error);
  }
};
