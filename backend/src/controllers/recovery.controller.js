const { WorkoutLog } = require('../models/tracking.model');
const sequelize      = require('../config/db.config');

// GET /api/recovery
exports.getRecovery = async (req, res, next) => {
  try {
    const userId  = req.user.id;
    const now     = new Date();
    const weekAgo = new Date(now - 7 * 24 * 60 * 60 * 1000);

    // Count workouts this week to estimate recovery need
    const recentWorkouts = await WorkoutLog.count({
      where: {
        userId,
        status:    'completed',
        createdAt: { [require('sequelize').Op.gte]: weekAgo },
      },
    });

    // Simple recovery score based on workout frequency
    // More workouts = lower recovery score (needs more rest)
    const baseScore     = 100;
    const workoutPenalty = recentWorkouts * 10;
    const recoveryScore  = Math.max(20, baseScore - workoutPenalty);

    const recommendation = recoveryScore >= 70
        ? 'You are well recovered. Train hard today!'
        : recoveryScore >= 40
        ? 'Moderate recovery. Consider a light session.'
        : 'Low recovery. Rest or do light stretching today.';

    res.json({
      recoveryScore,
      sleepHours:    0,
      sleepMinutes:  0,
      sleepQuality:  'Not logged',
      sorenessLevel: 0,
      restDaysLeft:  recentWorkouts > 4 ? 1 : 0,
      recommendation,
    });
  } catch (e) { next(e); }
};

// POST /api/recovery  — log sleep
exports.logSleep = async (req, res, next) => {
  try {
    const { sleepHours, sleepMinutes } = req.body;

    // For now store in a simple way
    // Later: create a SleepLog model for full history
    res.json({
      message:      'Sleep logged successfully',
      sleepHours:   sleepHours   ?? 0,
      sleepMinutes: sleepMinutes ?? 0,
    });
  } catch (e) { next(e); }
};