require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const User = require('./src/models/User');

const seedAdmin = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || process.env.MONGO_URI;
    if (!mongoURI) {
      console.error('MONGODB_URI is missing in .env');
      process.exit(1);
    }
    
    await mongoose.connect(mongoURI);
    console.log('Connected to MongoDB');

    const email = 'admin@rideal.com';
    const password = 'admin'; // simple password for testing

    const existingAdmin = await User.findOne({ email });
    if (existingAdmin) {
      console.log('Admin user already exists:', email);
      process.exit(0);
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const suffix = Math.floor(1000 + Math.random() * 9000);
    const adminUser = new User({
      userId: `admin_${Date.now()}`,
      username: `admin_${suffix}`,
      email: email,
      passwordHash: passwordHash,
      role: 'admin',
      isProfileComplete: true,
      fullName: 'Super Admin'
    });

    await adminUser.save();
    console.log('Admin user created successfully!');
    console.log('Email:', email);
    console.log('Password:', password);
    process.exit(0);
  } catch (error) {
    console.error('Error seeding admin:', error);
    process.exit(1);
  }
};

seedAdmin();
