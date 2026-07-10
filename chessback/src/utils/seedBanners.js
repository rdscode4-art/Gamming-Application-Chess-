require('dotenv').config();
const mongoose = require('mongoose');
const Banner = require('../models/Banner');
const logger = require('../config/logger');

const seedBanners = [
  {
    title: 'Weekend Rapid Tournament',
    subtitle: 'Prize Pool: ₹50,000',
    cta: 'Join Now',
    color: '#9C27B0', // Purple
    icon: 'emoji_events',
    order: 1
  },
  {
    title: 'Classic Championship',
    subtitle: 'Entry: ₹99 • 128 Players',
    cta: 'Register',
    color: '#FFD700', // Gold
    icon: 'account_balance',
    order: 2
  },
  {
    title: 'Free Daily Blitz',
    subtitle: 'No entry fee • Win ₹500',
    cta: 'Play Free',
    color: '#4CAF50', // Green
    icon: 'flash_on',
    order: 3
  }
];

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    logger.info('Connected to MongoDB');

    // Clear existing
    await Banner.deleteMany({});
    
    await Banner.insertMany(seedBanners);
    
    logger.info('Banners seeded successfully!');
    process.exit(0);
  } catch (error) {
    logger.error(`Seeding error: ${error.message}`);
    process.exit(1);
  }
};

seed();
