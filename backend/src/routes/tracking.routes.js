const express = require('express');
const router = express.Router();
const trackingController = require('../controllers/tracking.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/start', protect, trackingController.startWorkout);
router.post('/set', protect, trackingController.logSet);
router.post('/finish/:id', protect, trackingController.finishWorkout);

module.exports = router;