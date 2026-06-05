const { Op }          = require('sequelize');
const User             = require('../models/user.model');
const { WorkoutLog }   = require('../models/tracking.model');
const { Achievement, UserAchievement, XpLog } = require('../models/social.model');
const constants        = require('../utils/gamification_constants');

class GamificationService {

  // ── Called by tracking.service after every finished workout ───
  async processWorkoutCompletion({ userId, durationSec, totalVolume, totalSets }) {
    // XP formula: base + volume bonus + duration bonus
    const baseXp      = constants.WORKOUT_COMPLETE_XP ?? 100;
    const volumeBonus = Math.floor((totalVolume  ?? 0) / 1000) * 10;
    const timeBonus   = Math.floor((durationSec  ?? 0) / 600)  * 5;
    const xpEarned    = baseXp + volumeBonus + timeBonus;

    const { newLevel, leveledUp } = await this.addXp(userId, xpEarned, 'Workout completed');

    // Check achievements separately — pass flag to avoid recursion
    const achievements = await this.checkAchievements(userId);

    return {
      xpEarned,
      newLevel:     leveledUp ? newLevel : null,
      achievements,                              // newly unlocked badges
    };
  }

  // ── Add XP + handle level up ───────────────────────────────────
  async addXp(userId, amount, reason, _skipAchievementCheck = false) {
    const user    = await User.findByPk(userId);
    let newXp     = (user.xp    ?? 0) + amount;
    let newLevel  = (user.level ?? 1);

    // Exponential level curve
    let xpRequired = this._xpForLevel(newLevel);
    let leveledUp  = false;

    while (newXp >= xpRequired) {
      newXp    -= xpRequired;
      newLevel++;
      leveledUp = true;
      xpRequired = this._xpForLevel(newLevel);
    }

    await user.update({ xp: newXp, level: newLevel });
    await XpLog.create({ userId, amount, reason });

    if (leveledUp) {
      console.log(`🎉 User ${userId} leveled up to ${newLevel}!`);
    }

    return { newXp, newLevel, leveledUp };
  }

  // ── Check and unlock achievements ──────────────────────────────
  // Returns array of newly unlocked achievement names
  async checkAchievements(userId) {
    const workoutCount = await WorkoutLog.count({
      where: { userId, status: 'completed' },
    });

    const eligible = await Achievement.findAll({
      where: {
        criteriaType:  'total_workouts',
        criteriaValue: { [Op.lte]: workoutCount },
      },
    });

    const newlyUnlocked = [];

    for (const ach of eligible) {
      const [, created] = await UserAchievement.findOrCreate({
        where: { userId, achievementId: ach.id },
      });

      if (created) {
        newlyUnlocked.push({ name: ach.name, icon: ach.icon });

        // Award XP for badge — pass flag to SKIP recursive achievement check
        await this.addXp(userId, ach.xpReward ?? 50, `Badge: ${ach.name}`, true);
      }
    }

    return newlyUnlocked;
  }

  // ── XP needed to reach next level ─────────────────────────────
  _xpForLevel(level) {
    const base       = constants.LEVEL_BASE_XP   ?? 500;
    const multiplier = constants.LEVEL_MULTIPLIER ?? 1.2;
    return Math.floor(level * base * multiplier);
  }
}

module.exports = new GamificationService();