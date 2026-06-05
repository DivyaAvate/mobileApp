const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exercise.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/', protect, exerciseController.getExercises);
router.get('/:id', protect, exerciseController.getExerciseDetail);

module.exports = router;