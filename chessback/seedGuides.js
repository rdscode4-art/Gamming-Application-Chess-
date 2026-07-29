require('dotenv').config();
const mongoose = require('mongoose');
const ChessGuide = require('./src/models/ChessGuide');

const guidesData = [
  {
    title: 'The Basics of Chess',
    content: 'Chess is a two-player strategy board game played on a checkered board with 64 squares arranged in an 8x8 grid. The objective is to checkmate the opponent\'s king.',
    mediaType: 'none',
    mediaUrl: '',
    order: 1
  },
  {
    title: 'Piece Movements',
    content: '• Pawn: Moves forward one square, but captures diagonally.\n• Knight: Moves in an L-shape (two squares in one direction, then one perpendicular).\n• Bishop: Moves diagonally any number of squares.\n• Rook: Moves horizontally or vertically any number of squares.\n• Queen: Combines the power of the Rook and Bishop.\n• King: Moves one square in any direction.',
    mediaType: 'none',
    mediaUrl: '',
    order: 2
  },
  {
    title: 'Special Rules',
    content: '• Castling: A move to protect your king and activate your rook.\n• En Passant: A special pawn capture rule.\n• Promotion: When a pawn reaches the opposite end of the board, it can become any other piece (usually a Queen).',
    mediaType: 'none',
    mediaUrl: '',
    order: 3
  },
  {
    title: 'Basic Strategies',
    content: '1. Control the center of the board.\n2. Develop your pieces quickly.\n3. Protect your King (castle early).\n4. Don\'t give away your pieces for free.',
    mediaType: 'none',
    mediaUrl: '',
    order: 4
  }
];

const seedGuides = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || process.env.MONGO_URI;
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to MongoDB');

    // Optional: Clear existing guides before seeding
    // await ChessGuide.deleteMany({});
    // console.log('Cleared existing guides');

    await ChessGuide.insertMany(guidesData);
    console.log('Successfully seeded old chess guides into the database!');

    mongoose.connection.close();
  } catch (error) {
    console.error('Error seeding guides:', error);
    process.exit(1);
  }
};

seedGuides();
