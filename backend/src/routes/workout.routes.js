const express            = require('express');
const router             = express.Router();
const workoutController  = require('../controllers/workout.controller');
const { protect }        = require('../middlewares/auth.middleware');

router.post('/generate',     protect, workoutController.generatePlan);
router.get('/current',       protect, workoutController.getCurrentPlan);

module.exports = router;