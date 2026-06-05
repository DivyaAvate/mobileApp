const authService = require('../services/auth.service');

// POST /api/auth/register
exports.register = async (req, res, next) => {
  try {
    const { email, password, displayName } = req.body;

    if (!email || !password || !displayName) {
      return res.status(400).json({ message: 'Email, password and name are required' });
    }

    const user = await authService.register(email, password, displayName);
    res.status(201).json({
      message: 'User registered successfully',
      userId:  user.id,
    });
  } catch (error) {
    // Handle duplicate email gracefully
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
    // result should be: { accessToken, refreshToken, user }
    res.status(200).json(result);
  } catch (error) {
    // Only 401 for actual auth failures, not server errors
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

    // Delegate all JWT logic to authService — never in controller
    const result = await authService.refreshToken(token);
    res.status(200).json({ accessToken: result.accessToken });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(403).json({ message: 'Invalid or expired refresh token' });
    }
    next(error);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: ['id', 'email', 'displayName', 'level', 'xp', 'role', 'isOnboarded']
    });
    res.json(user);
  } catch (e) { next(e); }
};