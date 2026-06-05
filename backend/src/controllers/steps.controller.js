const sequelize = require('../config/db.config');

// POST /api/steps/sync
exports.syncSteps = async (req, res, next) => {
  try {
    const { steps, date } = req.body;
    const userId = req.user.id;

    if (!steps || !date) {
      return res.status(400).json({ message: 'steps and date are required' });
    }

    // UPSERT — insert or update if same user+date exists
    await sequelize.query(
      `INSERT INTO steps (user_id, step_count, activity_date)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE step_count = VALUES(step_count)`,
      { replacements: [userId, steps, date] }
    );

    res.status(200).json({ message: 'Steps synced', steps, date });
  } catch (e) { next(e); }
};

// GET /api/steps/trends
exports.getTrends = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const trends = await sequelize.query(
      `SELECT activity_date AS date, step_count AS steps
       FROM steps
       WHERE user_id = ?
       ORDER BY activity_date DESC
       LIMIT 30`,
      { replacements: [userId], type: sequelize.QueryTypes.SELECT }
    );
    res.status(200).json(trends);
  } catch (e) { next(e); }
};

// GET /api/steps/today
exports.getTodaySteps = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const today  = new Date().toISOString().split('T')[0];

    const [result] = await sequelize.query(
      `SELECT step_count AS steps FROM steps
       WHERE user_id = ? AND activity_date = ?`,
      { replacements: [userId, today], type: sequelize.QueryTypes.SELECT }
    );

    res.status(200).json({ steps: result?.steps ?? 0, date: today });
  } catch (e) { next(e); }
};