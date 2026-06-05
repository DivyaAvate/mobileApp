const express       = require('express');
const router        = express.Router();
const gymController = require('../controllers/gym.controller');
const { protect }   = require('../middlewares/auth.middleware');

// ─── Public ───────────────────────────────────────────────────────────────────
router.get('/',                               gymController.listGyms);

// ─── Member (protected) ───────────────────────────────────────────────────────
router.post('/join',         protect,         gymController.joinGym);
router.get('/my-gym',        protect,         gymController.getMyGym);
router.get('/:gymId/offers', protect,         gymController.getGymOffers);

// ─── Gym Owner (protected) ────────────────────────────────────────────────────
router.post('/create',                   protect, gymController.createGym);
router.get('/:gymId/members',            protect, gymController.getGymMembers);
router.get('/:gymId/members/:memberId',  protect, gymController.getMemberData);
router.post('/:gymId/offers',            protect, gymController.createOffer);
router.delete('/:gymId/offers/:offerId', protect, gymController.deleteOffer);

module.exports = router;