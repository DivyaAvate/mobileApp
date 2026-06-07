const express = require('express');
const router  = express.Router();
const { protect } = require('../middlewares/auth.middleware');
const progressController = require('../controllers/progress.controller');

router.get('/', protect, progressController.getProgress);
module.exports = router;