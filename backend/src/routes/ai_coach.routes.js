const express           = require('express');
const router            = express.Router();
const aiCoachController = require('../controllers/ai_coach.controller');
const { protect }       = require('../middlewares/auth.middleware');

router.post('/ask', protect, aiCoachController.askCoach);

module.exports = router;