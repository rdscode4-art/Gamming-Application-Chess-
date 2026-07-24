const Tournament = require('../../models/Tournament');
const { v4: uuidv4 } = require('uuid');

exports.getTournaments = async (req, res, next) => {
  try {
    const tourneys = await Tournament.find().sort({ startTime: 1 });
    res.json(tourneys);
  } catch (error) { next(error); }
};

exports.createTournament = async (req, res, next) => {
  try {
    const { name, description, format, timeControl, maxPlayers, entryFee, startTime, isPrivate, customDistribution = [100] } = req.body;

    const SystemSetting = require('../../models/SystemSetting');
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

    const data = { 
      ...req.body, 
      tournamentId: req.body.tournamentId || uuidv4(),
      createdBy: 'admin_dashboard',
      createdByRole: 'admin',
      prizePool,
      platformFee,
      prizeDistribution
    };
    const newTourney = await Tournament.create(data);
    res.status(201).json(newTourney);
  } catch (error) { next(error); }
};

exports.updateTournament = async (req, res, next) => {
  try {
    const updatedTourney = await Tournament.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updatedTourney);
  } catch (error) { next(error); }
};

exports.deleteTournament = async (req, res, next) => {
  try {
    await Tournament.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (error) { next(error); }
};
