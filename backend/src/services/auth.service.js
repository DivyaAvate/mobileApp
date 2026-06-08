const bcrypt       = require('bcryptjs');
const jwt          = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const User         = require('../models/user.model');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

class AuthService {

  // ── Token generation ───────────────────────────────────────
  generateTokens(user) {
    const payload = { id: user.id };

    const accessToken = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      payload,
      process.env.JWT_REFRESH_SECRET, // separate secret for refresh
      { expiresIn: '7d' }
    );

    return { accessToken, refreshToken };
  }

  // ── Register ───────────────────────────────────────────────
  async register(email, password, displayName, role = 'member') {
    const existing = await User.findOne({ where: { email } });
    if (existing) throw new Error('User already exists');

    const user = await User.create({
      email,
      password,
      displayName,
      role,           // ← save role
      isVerified: false,
    });
    return user;
  }

  // ── Login ──────────────────────────────────────────────────
  async login(email, password) {
    const user = await User.findOne({ where: { email } });

    // Use constant-time comparison to prevent timing attacks
    const valid = user && await bcrypt.compare(password, user.password);
    if (!valid) throw new Error('Invalid credentials');

    const tokens = this.generateTokens(user);
    return {
      user: {
        id:          user.id,
        email:       user.email,
        displayName: user.displayName,
        role:        user.role,           // ← ADD THIS
         isOnboarded: user.isOnboarded,    // ← ADD THIS
        level:       user.level,
        xp:          user.xp,
        role:        user.role,
        isOnboarded: user.isOnboarded,
      },
      ...tokens,
    };
  }

  // ── Google Login ───────────────────────────────────────────
  async googleLogin(idToken) {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const { email, sub: googleId, name } = ticket.getPayload();

    let user = await User.findOne({ where: { email } });
    if (!user) {
      user = await User.create({
        email,
        googleId,
        displayName: name,
        isVerified:  true,
        password:    null, // Google users have no password
      });
    }

    const tokens = this.generateTokens(user);
    return {
      user: {
        id:          user.id,
        email:       user.email,
        displayName: user.displayName,
        level:       user.level,
        xp:          user.xp,
        role:        user.role,
        isOnboarded: user.isOnboarded,
      },
      ...tokens,
    };
  }

  // ── Refresh Token ──────────────────────────────────────────
  async refreshToken(token) {
    // Verify using refresh secret — NOT the access secret
    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);

    const user = await User.findByPk(decoded.id);
    if (!user) throw new Error('User not found');

    // Issue a new access token only
    const accessToken = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    return { accessToken };
  }
}

module.exports = new AuthService();