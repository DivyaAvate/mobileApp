const express         = require('express');
const router          = express.Router();
const stepsController = require('../controllers/steps.controller');
const { protect }     = require('../middlewares/auth.middleware');

router.post('/sync',   protect, stepsController.syncSteps);
router.get('/trends',  protect, stepsController.getTrends);
router.get('/today',   protect, stepsController.getTodaySteps);

module.exports = router;