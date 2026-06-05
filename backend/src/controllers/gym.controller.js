const gymService = require('../services/gym.service');

// ─── Public ───────────────────────────────────────────────────────────────────

// GET /api/gyms  — list all gyms for member to browse
exports.listGyms = async (req, res, next) => {
  try {
    const { city, search } = req.query;
    const gyms = await gymService.listGyms({ city, search });
    res.status(200).json(gyms);
  } catch (e) { next(e); }
};

// ─── Member ───────────────────────────────────────────────────────────────────

// POST /api/gyms/join  — member joins a gym
exports.joinGym = async (req, res, next) => {
  try {
    const { gymId } = req.body;
    if (!gymId) return res.status(400).json({ message: 'gymId is required' });

    const result = await gymService.joinGym(req.user.id, gymId);
    res.status(200).json({
      message:      'Successfully joined gym!',
      referralCode: result.referralCode,
      gymName:      result.gymName,
      gymLogo:      result.gymLogo,
    });
  } catch (e) { next(e); }
};

// GET /api/gyms/my-gym  — get member's current gym
exports.getMyGym = async (req, res, next) => {
  try {
    const gym = await gymService.getMemberGym(req.user.id);
    if (!gym) return res.status(404).json({ message: 'Not a member of any gym' });
    res.status(200).json(gym);
  } catch (e) { next(e); }
};

// GET /api/gyms/:gymId/offers — get active offers for a gym
exports.getGymOffers = async (req, res, next) => {
  try {
    const offers = await gymService.getGymOffers(req.params.gymId);
    res.status(200).json(offers);
  } catch (e) { next(e); }
};

// ─── Gym Owner ────────────────────────────────────────────────────────────────

// POST /api/gyms/create — gym owner creates their gym
exports.createGym = async (req, res, next) => {
  try {
    const { name, logoUrl, address, city, phone, description } = req.body;
    if (!name) return res.status(400).json({ message: 'Gym name is required' });

    const gym = await gymService.createGym(req.user.id, {
      name, logoUrl, address, city, phone, description,
    });
    res.status(201).json({ message: 'Gym created successfully!', gym });
  } catch (e) { next(e); }
};

// GET /api/gyms/:gymId/members — get all members
exports.getGymMembers = async (req, res, next) => {
  try {
    const members = await gymService.getGymMembers(
      req.params.gymId,
      req.user.id,
    );
    res.status(200).json(members);
  } catch (e) { next(e); }
};

// GET /api/gyms/:gymId/members/:memberId — get full member data
exports.getMemberData = async (req, res, next) => {
  try {
    const data = await gymService.getMemberFullData(
      req.params.gymId,
      req.params.memberId,
      req.user.id,
    );
    res.status(200).json(data);
  } catch (e) { next(e); }
};

// POST /api/gyms/:gymId/offers — create offer
exports.createOffer = async (req, res, next) => {
  try {
    const { title, description, imageUrl, type, expiresAt } = req.body;
    if (!title) return res.status(400).json({ message: 'Title is required' });

    const offer = await gymService.createOffer(
      req.params.gymId,
      req.user.id,
      { title, description, imageUrl, type, expiresAt },
    );
    res.status(201).json({ message: 'Offer posted!', offer });
  } catch (e) { next(e); }
};

// DELETE /api/gyms/:gymId/offers/:offerId — delete offer
exports.deleteOffer = async (req, res, next) => {
  try {
    await gymService.deleteOffer(
      req.params.offerId,
      req.params.gymId,
      req.user.id,
    );
    res.status(200).json({ message: 'Offer removed' });
  } catch (e) { next(e); }
};