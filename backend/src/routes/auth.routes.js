const express        = require('express');
const router         = express.Router();
const authController = require('../controllers/auth.controller');
const { protect }    = require('../middlewares/auth.middleware');

// ─── Public ───────────────────────────────────────────────────────────────────
router.post('/register',      authController.register);
router.post('/login',         authController.login);
router.post('/google',        authController.googleAuth);
router.post('/refresh-token', authController.refreshToken);

// ─── Protected ────────────────────────────────────────────────────────────────
router.get('/profile',  protect, authController.getProfile);
router.post('/profile', protect, authController.updateProfile);
router.post('/logout',  protect, authController.logout);

module.exports = router;