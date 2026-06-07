const express             = require('express');
const router              = express.Router();
const { protect }         = require('../middlewares/auth.middleware');
const recoveryController  = require('../controllers/recovery.controller');

router.get('/',  protect, recoveryController.getRecovery);
router.post('/', protect, recoveryController.logSleep);

module.exports = router;