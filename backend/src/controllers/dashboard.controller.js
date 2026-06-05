const { WorkoutLog, ExerciseLog, SetLog } = require('../models/tracking.model');
const User = require('../models/user.model');
const { WorkoutPlan, WorkoutDay } = require('../models/workout_plan.model');
const sequelize = require('../config/db.config');
const { Op } = require('sequelize');

exports.getDashboardData = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const today = new Date().toISOString().split('T')[0];

        // 1. Fetch User Stats (Streak, XP)
        const user = await User.findByPk(userId, { attributes: ['xp', 'streak_count', 'displayName'] });

        // 2. Fetch Today's Workout
        const todayWorkout = await WorkoutPlan.findOne({
            where: { userId, isActive: true },
            include: [{ 
                model: WorkoutDay, 
                as: 'days',
                where: { dayNumber: (new Date().getDay() || 7) } // Match current day of week
            }]
        });

        // 3. Weekly Activity Data (Last 7 Days)
        const weeklyActivity = await WorkoutLog.findAll({
            where: {
                userId,
                startTime: { [Op.gte]: sequelize.literal('NOW() - INTERVAL 7 DAY') }
            },
            attributes: [
                [sequelize.fn('DATE', sequelize.col('startTime')), 'date'],
                [sequelize.fn('SUM', sequelize.col('totalVolume')), 'volume']
            ],
            group: [sequelize.fn('DATE', sequelize.col('startTime'))],
            order: [[sequelize.fn('DATE', sequelize.col('startTime')), 'ASC']]
        });

        // 4. Mocking Steps & Recovery Score (In production, these come from their respective tables)
        const steps = 8432; 
        const recoveryScore = 78;

        res.json({
            user,
            todayWorkout: todayWorkout ? todayWorkout.days[0] : null,
            stats: { steps, recoveryScore },
            weeklyActivity
        });
    } catch (e) { next(e); }
};