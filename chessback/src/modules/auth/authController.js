const User = require('../../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const SystemSetting = require('../../models/SystemSetting');

// ─── Token Helpers ──────────────────────────────────────────────────────────

const generateAccessToken = (user) => {
  return jwt.sign(
    { userId: user.userId, username: user.username, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

const generateRefreshToken = (user) => {
  return jwt.sign(
    { userId: user.userId },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

// ─── Guest Login (kept for backwards compat) ────────────────────────────────

exports.guestLogin = async (req, res, next) => {
  try {
    const { username } = req.body;

    if (!username || username.length < 3) {
      return res.status(400).json({ message: 'Username must be at least 3 characters long' });
    }

    let user = await User.findOne({ username });

    if (user && !user.isGuest) {
      return res.status(400).json({ message: 'Username is taken by a registered user' });
    }

    if (!user) {
      user = await User.create({
        userId: uuidv4(),
        username,
        isGuest: true,
        isProfileComplete: true
      });
    }

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    user.refreshToken = await bcrypt.hash(refreshToken, 8);
    await user.save();

    res.status(200).json({
      accessToken,
      refreshToken,
      user: {
        userId: user.userId,
        username: user.username,
        playerId: user.playerId,
        rating: user.rating,
        classicRating: user.classicRating,
        rapidRating: user.rapidRating,
        avatarUrl: user.avatarUrl,
        isGuest: user.isGuest,
        role: user.role,
        isProfileComplete: user.isProfileComplete,
      }
    });

  } catch (error) {
    next(error);
  }
};

// ─── Request OTP ────────────────────────────────────────────────────────────

exports.requestOtp = async (req, res, next) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required' });
    }

    // In a real app, integrate Twilio/MSG91 here.
    // For now, we mock the OTP.
    const mockOtp = '123456';
    
    // Log the OTP for debugging purposes.
    console.log(`[OTP] Sent OTP ${mockOtp} to phone ${phoneNumber}`);

    res.status(200).json({
      message: 'OTP sent successfully',
      // In production, NEVER send the OTP back in the response!
      // mockOtp: mockOtp
    });
  } catch (error) {
    next(error);
  }
};

// ─── Verify OTP ─────────────────────────────────────────────────────────────

exports.verifyOtp = async (req, res, next) => {
  try {
    const { phoneNumber, otp } = req.body;

    if (!phoneNumber || !otp) {
      return res.status(400).json({ message: 'Phone number and OTP are required' });
    }

    // Mock validation
    if (otp !== '123456') {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    let user = await User.findOne({ phoneNumber }).select('+passwordHash');

    if (!user) {
      // New user registration flow
      const myReferralCode = `REF${uuidv4().slice(0, 6).toUpperCase()}`;
      
      // Generate a temporary username to satisfy the model requirement
      const tempUsername = `user_${uuidv4().slice(0, 8)}`;

      user = await User.create({
        userId: uuidv4(),
        phoneNumber,
        username: tempUsername,
        isGuest: false,
        isProfileComplete: false,
        referralCode: myReferralCode,
        bonusBalance: 0,
      });
    } else {
      if (user.isBanned) {
        return res.status(403).json({ message: `Account banned: ${user.banReason || 'Policy violation'}` });
      }
    }

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    user.refreshToken = await bcrypt.hash(refreshToken, 8);
    await user.save();

    res.status(200).json({
      accessToken,
      refreshToken,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        phoneNumber: user.phoneNumber,
        playerId: user.playerId,
        rating: user.rating,
        classicRating: user.classicRating,
        rapidRating: user.rapidRating,
        avatarUrl: user.avatarUrl,
        isGuest: user.isGuest,
        role: user.role,
        isProfileComplete: user.isProfileComplete,
      }
    });

  } catch (error) {
    next(error);
  }
};

// ─── Check Username ───────────────────────────────────────────────────────────

exports.checkUsername = async (req, res, next) => {
  try {
    const { username } = req.body;
    if (!username || username.length < 3 || username.length > 20) {
      return res.status(400).json({ message: 'Username must be 3-20 characters' });
    }
    const user = await User.findOne({ username });
    if (user) {
      return res.status(200).json({ available: false, message: 'Username is already taken' });
    }
    return res.status(200).json({ available: true, message: 'Username is available' });
  } catch (error) {
    next(error);
  }
};

// ─── Complete Profile ───────────────────────────────────────────────────────

exports.completeProfile = async (req, res, next) => {
  try {
    const { username, email, fullName, referralCode } = req.body;
    
    if (!username || username.length < 3 || username.length > 20) {
      return res.status(400).json({ message: 'Username must be 3-20 characters' });
    }

    // Check if new username or email is already taken
    const existingUser = await User.findOne({
      $or: [{ username }, { email }],
      _id: { $ne: req.user._id } // exclude current user
    });

    if (existingUser) {
      const field = existingUser.username === username ? 'Username' : 'Email';
      return res.status(400).json({ message: `${field} is already taken` });
    }

    const user = await User.findOne({ userId: req.user.userId });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.username = username;
    if (email) user.email = email;
    if (fullName) user.fullName = fullName;
    user.isProfileComplete = true;

    // Handle referral logic if a referral code is provided and the user hasn't been referred yet
    if (referralCode && !user.referredBy) {
      const referrer = await User.findOne({ referralCode });
      if (referrer && referrer.userId !== user.userId) {
        let rewardAmount = 50; // default fallback
        try {
          const setting = await SystemSetting.findOne({ key: 'referral_reward_amount' });
          if (setting && setting.value) {
            rewardAmount = Number(setting.value);
          }
        } catch (err) {
          console.error("Error fetching referral_reward_amount from SystemSettings", err);
        }

        user.referredBy = referrer.userId;
        user.bonusBalance += rewardAmount; // Bonus for the new user
        
        referrer.bonusBalance += rewardAmount; // Bonus for the referrer
        referrer.referralCount += 1;
        await referrer.save();
      }
    }

    await user.save();

    // Re-issue tokens since username might have changed in payload
    const accessToken = generateAccessToken(user);
    
    res.status(200).json({
      message: 'Profile completed successfully',
      accessToken,
      user: {
        userId: user.userId,
        username: user.username,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        playerId: user.playerId,
        rating: user.rating,
        avatarUrl: user.avatarUrl,
        isGuest: user.isGuest,
        role: user.role,
        bonusBalance: user.bonusBalance,
        isProfileComplete: user.isProfileComplete,
      }
    });

  } catch (error) {
    next(error);
  }
};


// ─── Refresh Token ───────────────────────────────────────────────────────────

exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({ message: 'Refresh token required' });
    }

    let decoded;
    try {
      decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET);
    } catch {
      return res.status(401).json({ message: 'Invalid or expired refresh token' });
    }

    const user = await User.findOne({ userId: decoded.userId }).select('+refreshToken');
    if (!user || !user.refreshToken) {
      return res.status(401).json({ message: 'Session expired. Please login again.' });
    }

    const isValid = await bcrypt.compare(refreshToken, user.refreshToken);
    if (!isValid) {
      return res.status(401).json({ message: 'Invalid refresh token' });
    }

    // Rotate refresh token
    const newAccessToken = generateAccessToken(user);
    const newRefreshToken = generateRefreshToken(user);

    user.refreshToken = await bcrypt.hash(newRefreshToken, 8);
    await user.save();

    res.status(200).json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });

  } catch (error) {
    next(error);
  }
};

// ─── Logout ─────────────────────────────────────────────────────────────────

exports.logout = async (req, res, next) => {
  try {
    // req.user set by authMiddleware
    const user = await User.findOne({ userId: req.user.userId });
    if (user) {
      user.refreshToken = null;
      await user.save();
    }
    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
};
