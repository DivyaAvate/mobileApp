const { Gym, GymMembership, Offer } = require('../models/gym.model');
const { WorkoutLog, ExerciseLog, SetLog } = require('../models/tracking.model');
const { WorkoutPlan } = require('../models/workout_plan.model');
const User            = require('../models/user.model');
const crypto          = require('crypto');
const { Op }          = require('sequelize');

class GymService {

  // ── Generate unique referral code ──────────────────────────
  _generateReferralCode(gymId, userId) {
    const raw = `${gymId}-${userId}-${Date.now()}`;
    return crypto.createHash('md5').update(raw).digest('hex').slice(0, 8).toUpperCase();
  }

  // ── List all gyms (for member to browse) ──────────────────
  async listGyms({ city, search } = {}) {
    const where = { isActive: true };
    if (city)   where.city = city;
    if (search) where.name = { [Op.like]: `%${search}%` };

    return await Gym.findAll({
      where,
      attributes: ['id', 'name', 'logoUrl', 'address', 'city', 'phone', 'description'],
      order: [['name', 'ASC']],
    });
  }

  // ── Member joins a gym → auto-generate referral code ──────
  async joinGym(userId, gymId) {
    const gym = await Gym.findByPk(gymId);
    if (!gym) throw new Error('Gym not found');

    // Check if already a member
    const existing = await GymMembership.findOne({ where: { userId, gymId } });
    if (existing) return existing; // return existing membership

    const referralCode = this._generateReferralCode(gymId, userId);

    const membership = await GymMembership.create({
      userId,
      gymId,
      referralCode,
      role: 'member',
    });

    return {
      membership,
      referralCode,
      gymName: gym.name,
      gymLogo: gym.logoUrl,
    };
  }

  // ── Get member's current gym ───────────────────────────────
  async getMemberGym(userId) {
    const membership = await GymMembership.findOne({
      where: {
        userId,
        role: { [Op.in]: ['member', 'gym_owner'] },
      },
      include: [{ model: Gym, as: 'gym' }],
      order: [['joinedAt', 'DESC']],
    });
    return membership?.gym ?? null;
  }

  // ── Gym owner creates a gym ────────────────────────────────
  async createGym(ownerUserId, { name, logoUrl, address, city, phone, description }) {
    const gym = await Gym.create({
      name, logoUrl, address, city, phone, description,
      ownerUserId,
    });

    // Auto-enroll owner as gym_owner role
    const referralCode = this._generateReferralCode(gym.id, ownerUserId);
    await GymMembership.create({
      userId:       ownerUserId,
      gymId:        gym.id,
      referralCode,
      role:         'gym_owner',
    });

    return gym;
  }

  // ── Get all members of a gym (for gym owner) ───────────────
  async getGymMembers(gymId, ownerUserId) {
    await this._verifyOwner(gymId, ownerUserId);

    return await GymMembership.findAll({
      where:   { gymId, role: 'member' },
      include: [{
        model:      User,
        as:         'user',
        attributes: ['id', 'displayName', 'email', 'level', 'xp'],
      }],
      order: [['joinedAt', 'DESC']],
    });
  }

  // ── Get full data of a specific member (for gym owner) ────
  async getMemberFullData(gymId, memberId, ownerUserId) {
    await this._verifyOwner(gymId, ownerUserId);

    // Verify member belongs to this gym
    const membership = await GymMembership.findOne({
      where: { gymId, userId: memberId },
    });
    if (!membership) throw new Error('Member not in this gym');

    const [user, workoutLogs, currentPlan] = await Promise.all([
      // Profile
      User.findByPk(memberId, {
        attributes: ['id', 'displayName', 'email', 'level', 'xp'],
      }),
      // Full workout history
      WorkoutLog.findAll({
        where:   { userId: memberId, status: 'completed' },
        include: [{
          model: ExerciseLog,
          as:    'exercises',
          include: [{ model: SetLog, as: 'sets' }],
        }],
        order: [['createdAt', 'DESC']],
        limit: 20,
      }),
      // Current active plan
      WorkoutPlan.findOne({
        where: { userId: memberId, isActive: true },
      }),
    ]);

    return { user, workoutLogs, currentPlan };
  }

  // ── Post an offer/announcement ────────────────────────────
  async createOffer(gymId, ownerUserId, { title, description, imageUrl, type, expiresAt }) {
    await this._verifyOwner(gymId, ownerUserId);
    return await Offer.create({
      gymId, title, description, imageUrl,
      type:      type      ?? 'announcement',
      expiresAt: expiresAt ?? null,
    });
  }

  // ── Get active offers for a gym (shown to members) ────────
  async getGymOffers(gymId) {
    return await Offer.findAll({
      where: {
        gymId,
        isActive: true,
        [Op.or]: [
          { expiresAt: null },
          { expiresAt: { [Op.gt]: new Date() } },
        ],
      },
      order: [['createdAt', 'DESC']],
    });
  }

  // ── Delete an offer ────────────────────────────────────────
  async deleteOffer(offerId, gymId, ownerUserId) {
    await this._verifyOwner(gymId, ownerUserId);
    await Offer.update({ isActive: false }, { where: { id: offerId, gymId } });
  }

  // ── Verify requesting user is gym owner ───────────────────
  async _verifyOwner(gymId, userId) {
    const membership = await GymMembership.findOne({
      where: { gymId, userId, role: 'gym_owner' },
    });
    if (!membership) throw new Error('Access denied — not the gym owner');
  }
}

module.exports = new GymService();