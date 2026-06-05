const { WorkoutLog, ExerciseLog, SetLog } = require('../models/tracking.model');
const sequelize = require('../config/db.config');
const { Op }    = require('sequelize');

// GET /api/progress
exports.getProgress = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const now    = new Date();
    const weekAgo = new Date(now - 7  * 24 * 60 * 60 * 1000);
    const monthAgo = new Date(now - 30 * 24 * 60 * 60 * 1000);

    // 1. Total workouts + volume
    const allLogs = await WorkoutLog.findAll({
      where: { userId, status: 'completed' },
      order: [['createdAt', 'DESC']],
    });
    const totalWorkouts  = allLogs.length;
    const totalVolume    = allLogs.reduce((s, l) => s + (l.totalVolume || 0), 0);
    const weeklyWorkouts = allLogs.filter(l =>
      new Date(l.createdAt) >= weekAgo).length;

    // 2. Weekly volume by day
    const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    const weeklyVolume = days.map((label, i) => {
      const dayLogs = allLogs.filter(l => {
        const d = new Date(l.createdAt);
        return d >= weekAgo && d.getDay() === i;
      });
      const volume = dayLogs.reduce((s, l) => s + (l.totalVolume || 0), 0);
      return { label, volume };
    });

    // 3. Personal records — best set per exercise
    const prRows = await sequelize.query(`
      SELECT e.name AS exerciseName,
             MAX(s.weight) AS weightKg,
             s.reps
      FROM set_logs s
      JOIN exercise_logs el ON s.exercise_log_id = el.id
      JOIN workout_logs wl  ON el.workout_log_id = wl.id
      JOIN exercises e      ON el.exercise_id = e.id
      WHERE wl.user_id = :userId
      GROUP BY el.exercise_id, e.name, s.reps
      ORDER BY weightKg DESC
      LIMIT 10
    `, {
      replacements: { userId },
      type: sequelize.QueryTypes.SELECT,
    });

    // 4. Recent workouts
    const recentWorkouts = allLogs.slice(0, 10).map(l => ({
      name:        l.name || 'Workout',
      totalSets:   l.totalSets   || 0,
      totalVolume: l.totalVolume || 0,
      durationSec: l.durationSec || 0,
      dateLabel:   new Date(l.createdAt).toLocaleDateString('en-IN', {
        day: 'numeric', month: 'short',
      }),
    }));

    res.json({
      totalWorkouts,
      totalVolume,
      weeklyWorkouts,
      weeklyVolume,
      personalRecords: prRows,
      weightHistory:   [],    // wire when body weight tracking added
      recentWorkouts,
    });
  } catch (e) { next(e); }
};