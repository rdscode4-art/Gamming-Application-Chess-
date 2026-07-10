const GameMode = require('../../models/GameMode');
const { v4: uuidv4 } = require('uuid');

exports.getGameModes = async (req, res, next) => {
  try {
    const modes = await GameMode.find().sort({ order: 1 });
    res.json(modes);
  } catch (error) { next(error); }
};

exports.createGameMode = async (req, res, next) => {
  try {
    const data = { ...req.body, modeId: req.body.modeId || uuidv4() };
    const newMode = await GameMode.create(data);
    res.status(201).json(newMode);
  } catch (error) { next(error); }
};

exports.updateGameMode = async (req, res, next) => {
  try {
    const updatedMode = await GameMode.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updatedMode);
  } catch (error) { next(error); }
};

exports.deleteGameMode = async (req, res, next) => {
  try {
    await GameMode.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (error) { next(error); }
};
