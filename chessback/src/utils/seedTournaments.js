require('dotenv').config();
const mongoose = require('mongoose');
const Tournament = require('../models/Tournament');
const logger = require('../config/logger');
const { v4: uuidv4 } = require('uuid');

const seedData = [
  {
    tournamentId: uuidv4(),
    name: 'Weekend Rapid Rumble',
    description: 'Join the weekend rapid chess tournament and win big!',
    format: 'knockout',
    timeControl: 'rapid_10',
    maxPlayers: 16,
    registeredPlayers: ['user_seed_1', 'user_seed_2', 'user_seed_3'],
    entryFee: 50,
    prizePool: 700,
    platformFee: 100,
    isPrivate: false,
    createdBy: 'admin',
    createdByRole: 'admin',
    startTime: new Date(Date.now() + 24 * 60 * 60 * 1000), // Tomorrow
    status: 'registration'
  },
  {
    tournamentId: uuidv4(),
    name: 'Sunday Bullet Championship',
    description: 'Fast paced 3+0 bullet chess.',
    format: 'swiss',
    timeControl: 'rapid_3',
    maxPlayers: 64,
    registeredPlayers: ['user_seed_4', 'user_seed_5'],
    entryFee: 10,
    prizePool: 500,
    platformFee: 140,
    isPrivate: false,
    createdBy: 'admin',
    createdByRole: 'admin',
    startTime: new Date(Date.now() + 48 * 60 * 60 * 1000), // Day after tomorrow
    status: 'registration'
  },
];

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    logger.info('Connected to MongoDB');

    // Optionally clear existing tournaments
    // await Tournament.deleteMany({});
    
    await Tournament.insertMany(seedData);
    
    logger.info('Tournaments seeded successfully!');
    process.exit(0);
  } catch (error) {
    logger.error(`Seeding error: ${error.message}`);
    process.exit(1);
  }
};

seed();
