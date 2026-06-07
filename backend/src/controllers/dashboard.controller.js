const { WorkoutLog }   = require('../models/tracking.model');
const { WorkoutPlan, WorkoutDay } = require('../models/workout_plan.model');
const User             = require('../models/user.model');
const sequelize        = require('../config/db.config');
const { Op }           = require('sequelize');

exports.getDashboardData = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const now    = new Date();
    const today  = now.toISOString().split('T')[0];

    // 1. User — use columns that actually exist in migration
    const user = await User.findByPk(userId, {
      attributes: ['id', 'displayName', 'xp', 'level'],
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // 2. Total workouts
    const totalWorkouts = await WorkoutLog.count({
      where: { userId, status: 'completed' },
    });

    // 3. Streak — count consecutive days backwards from today
    const recentLogs = await WorkoutLog.findAll({
      where:  { userId, status: 'completed' },
      order:  [['created_at', 'DESC']],
      limit:  60,
      attributes: ['created_at'],
    });

    const workedDays = new Set(
      recentLogs.map(l => new Date(l.createdAt).toISOString().split('T')[0])
    );
    let streakDays  = 0;
    const checkDate = new Date(now);
    checkDate.setHours(0, 0, 0, 0);
    while (workedDays.has(checkDate.toISOString().split('T')[0])) {
      streakDays++;
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // 4. Today's steps from Steps table
    const [stepsRow] = await sequelize.query(
      `SELECT step_count FROM Steps
       WHERE user_id = :userId AND activity_date = :today LIMIT 1`,
      { replacements: { userId, today }, type: sequelize.QueryTypes.SELECT }
    );
    const todaySteps = stepsRow?.step_count ?? 0;

    // 5. Today's workout name from active plan
    let todayWorkoutName = null;
    try {
      const dayNumber = now.getDay() || 7; // 1=Mon ... 7=Sun
      const plan = await WorkoutPlan.findOne({
        where:   { userId, isActive: true },
        include: [{
          model: WorkoutDay,
          as:    'days',
          where: { dayNumber },
        }],
      });
      todayWorkoutName = plan?.days?.[0]?.dayName ?? null;
    } catch (_) { /* no plan yet */ }

    // 6. Weekly volume by day (last 7 days)
    const weekAgo = new Date(now - 7 * 24 * 60 * 60 * 1000);
    const volumeRows = await WorkoutLog.findAll({
      where: {
        userId,
        status:     'completed',
        created_at: { [Op.gte]: weekAgo },
      },
      attributes: [
        [sequelize.fn('DATE', sequelize.col('created_at')), 'date'],
        [sequelize.fn('SUM',  sequelize.col('total_volume')), 'volume'],
      ],
      group: [sequelize.fn('DATE', sequelize.col('created_at'))],
      order: [[sequelize.fn('DATE', sequelize.col('created_at')), 'ASC']],
    });

    // Map to day labels
    const days        = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const volumeMap   = {};
    volumeRows.forEach(r => { volumeMap[r.dataValues.date] = r.dataValues.volume; });

    const weeklyActivity = Array.from({ length: 7 }, (_, i) => {
      const d     = new Date(weekAgo);
      d.setDate(d.getDate() + i + 1);
      const key   = d.toISOString().split('T')[0];
      return {
        label: days[d.getDay()],
        value: Number(volumeMap[key] ?? 0),
      };
    });

    // 7. Recovery score
    const workoutsThisWeek = recentLogs.filter(
      l => new Date(l.createdAt) >= weekAgo).length;
    const recoveryScore = Math.max(20, 100 - workoutsThisWeek * 10);

    res.json({
      userName:        user.displayName ?? 'Athlete',
      level:           user.level       ?? 1,
      xp:              user.xp          ?? 0,
      nextLevelXp:     Math.floor((user.level ?? 1) * 500 * 1.5),
      streakDays,
      totalWorkouts,
      todaySteps,
      todayWorkoutName,
      recoveryScore,
      weeklyActivity,
    });

  } catch (e) { next(e); }
};