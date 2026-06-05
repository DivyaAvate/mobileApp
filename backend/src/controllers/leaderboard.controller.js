const User = require('../models/user.model');
const sequelize = require('../config/db.config');

exports.getGlobalLeaderboard = async (req, res, next) => {
    try {
        // Query to get top users based on XP
        const topUsers = await User.findAll({
            attributes: ['id', 'displayName', 'xp', 'streak_count'],
            order: [['xp', 'DESC']],
            limit: 10
        });

        res.json(topUsers);
    } catch (e) { next(e); }
};