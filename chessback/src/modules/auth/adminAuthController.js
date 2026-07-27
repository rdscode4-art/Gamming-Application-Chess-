const User = require('../../models/User');
const jwt = require('jsonwebtoken');

exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ status: 'fail', message: 'Email and password are required' });
    }

    const user = await User.findOne({ email }).select('+passwordHash');
    
    if (!user) {
      return res.status(401).json({ status: 'fail', message: 'Invalid credentials' });
    }

    if (user.role !== 'admin') {
      return res.status(403).json({ status: 'fail', message: 'Access denied. Admins only.' });
    }

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
      return res.status(401).json({ status: 'fail', message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user.userId, username: user.username, role: user.role },
      process.env.JWT_SECRET || 'dev_secret',
      { expiresIn: '7d' }
    );

    res.status(200).json({
      status: 'success',
      data: {
        token,
        admin: {
          userId: user.userId,
          username: user.username,
          email: user.email,
          role: user.role
        }
      }
    });

  } catch (error) {
    console.error('Admin Login Error:', error);
    res.status(500).json({ status: 'error', message: 'Internal server error' });
  }
};
