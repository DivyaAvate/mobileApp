const authService = require('../services/auth.service');
const User        = require('../models/user.model');

// POST /api/auth/register
exports.register = async (req, res, next) => {
  try {
    const { email, password, displayName, role } = req.body; // ← add role
    if (!email || !password || !displayName) {
      return res.status(400).json({ message: 'Email, password and name are required' });
    }
    const user = await authService.register(email, password, displayName, role);
    res.status(201).json({ message: 'User registered successfully', userId: user.id });
  } catch (error) {
    if (error.message?.includes('already exists') || error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({ message: 'Email already registered' });
    }
    next(error);
  }
};

// POST /api/auth/login
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }
    const result = await authService.login(email, password);
    res.status(200).json(result);
  } catch (error) {
    if (error.message === 'Invalid credentials') {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
    next(error);
  }
};

// POST /api/auth/google
exports.googleAuth = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'Google ID token is required' });
    }
    const result = await authService.googleLogin(idToken);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/refresh-token
exports.refreshToken = async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(401).json({ message: 'Refresh token required' });
    }
    const result = await authService.refreshToken(token);
    res.status(200).json({ accessToken: result.accessToken });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(403).json({ message: 'Invalid or expired refresh token' });
    }
    next(error);
  }
};

// GET /api/auth/profile
exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: [
        'id', 'email', 'displayName', 'role',
        'isOnboarded', 'level', 'xp',
        'age', 'heightCm', 'weightKg', 'gender',
      ],
    });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (e) { next(e); }
};

// POST /api/auth/profile
exports.updateProfile = async (req, res, next) => {
  try {
    const { age, heightCm, weightKg, gender, isOnboarded } = req.body;
    await User.update(
      { age, heightCm, weightKg, gender, isOnboarded: isOnboarded ?? false },
      { where: { id: req.user.id } }
    );
    res.json({ message: 'Profile updated successfully' });
  } catch (e) { next(e); }
};

// POST /api/auth/logout
exports.logout = async (req, res, next) => {
  try {
    res.json({ message: 'Logged out successfully' });
  } catch (e) { next(e); }
};