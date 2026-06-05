const aiCoachService = require('../services/ai_coach.service');

// POST /api/coach/ask
exports.askCoach = async (req, res, next) => {
  try {
    const { message } = req.body;
    const userId      = req.user.id;

    if (!message?.trim()) {
      return res.status(400).json({ message: 'Message is required' });
    }

    const reply = await aiCoachService.askCoach(userId, message);
    res.status(200).json({ reply });
  } catch (e) { next(e); }
};