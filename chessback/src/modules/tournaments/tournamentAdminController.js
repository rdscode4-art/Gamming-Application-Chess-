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
    const data = { 
      ...req.body, 
      tournamentId: req.body.tournamentId || uuidv4(),
      createdBy: 'admin_dashboard'
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
