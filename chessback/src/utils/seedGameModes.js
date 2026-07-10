require('dotenv').config();
const mongoose = require('mongoose');
const GameMode = require('../models/GameMode');
const logger = require('../config/logger');

const seedModes = [
  // Free
  { modeId: 'free_rapid_3',   label: 'Bullet 3+0',   timeControl: 'rapid_3',    entryFee: 0,   prize: 0,    isRated: false, tag: 'Free',   order: 1 },
  { modeId: 'free_rapid_5',   label: 'Blitz 5+0',    timeControl: 'rapid_5',    entryFee: 0,   prize: 0,    isRated: false, tag: 'Free',   order: 2 },
  { modeId: 'free_rapid_10',  label: 'Rapid 10+0',   timeControl: 'rapid_10',   entryFee: 0,   prize: 0,    isRated: false, tag: 'Free',   order: 3 },
  // Rated
  { modeId: 'rated_rapid_5',  label: 'Rated 5+0',    timeControl: 'rapid_5',    entryFee: 0,   prize: 0,    isRated: true,  tag: 'Rated',  order: 4 },
  { modeId: 'rated_rapid_10', label: 'Rated 10+0',   timeControl: 'rapid_10',   entryFee: 0,   prize: 0,    isRated: true,  tag: 'Rated',  order: 5 },
  { modeId: 'rated_classic',  label: 'Rated 15+10',  timeControl: 'classic_15', entryFee: 0,   prize: 0,    isRated: true,  tag: 'Rated',  order: 6 },
  // Paid
  { modeId: 'paid_10',        label: '₹10 Match',    timeControl: 'rapid_10',   entryFee: 10,  prize: 18,   isRated: false, tag: '₹10',    order: 7 },
  { modeId: 'paid_25',        label: '₹25 Match',    timeControl: 'rapid_10',   entryFee: 25,  prize: 45,   isRated: false, tag: '₹25',    order: 8 },
  { modeId: 'paid_50',        label: '₹50 Match',    timeControl: 'rapid_10',   entryFee: 50,  prize: 90,   isRated: false, tag: '₹50',    order: 9 },
  { modeId: 'paid_100',       label: '₹100 Match',   timeControl: 'classic_15', entryFee: 100, prize: 180,  isRated: false, tag: '₹100',   order: 10 },
  { modeId: 'paid_500',       label: '₹500 Match',   timeControl: 'classic_30', entryFee: 500, prize: 900,  isRated: false, tag: '₹500',   order: 11 },
  { modeId: 'paid_1000',      label: '₹1000 Match',  timeControl: 'classic_60', entryFee: 1000,prize: 1800, isRated: false, tag: '₹1000',  order: 12 },
];

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    logger.info('Connected to MongoDB');

    for (const mode of seedModes) {
      await GameMode.findOneAndUpdate(
        { modeId: mode.modeId },
        { $set: mode },
        { upsert: true, new: true }
      );
    }
    
    logger.info('Game modes seeded successfully!');
    process.exit(0);
  } catch (error) {
    logger.error(`Seeding error: ${error.message}`);
    process.exit(1);
  }
};

seed();
