const { GoogleGenerativeAI } = require('@google/generative-ai');
const NodeCache              = require('node-cache');
const prompts                = require('../utils/ai_prompts');
const User                   = require('../models/user.model');

// Cache by message text only — same fitness Q = same A for everyone
const aiCache = new NodeCache({ stdTTL: 3600 });
const genAI   = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

class AICoachService {
  async askCoach(userId, userMessage) {
    // 1. Check cache — key by normalized message only
    const cacheKey = userMessage.toLowerCase().trim();
    if (aiCache.has(cacheKey)) return aiCache.get(cacheKey);

    // 2. Fetch user context for personalised response
    const user  = await User.findByPk(userId, {
      attributes: ['id', 'displayName', 'level', 'xp'],
    });

    // 3. Use current Gemini model (gemini-pro is deprecated)
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const chat = model.startChat({
      history: [
        {
          role:  'user',
          parts: [{ text: prompts.SYSTEM_PROMPT(user, {}) }],
        },
        {
          role:  'model',
          parts: [{ text: 'Understood. I am GymBuddy AI Coach, ready to help!' }],
        },
      ],
    });

    const result       = await chat.sendMessage(userMessage);
    const responseText = result.response.text();

    // 4. Cache the response
    aiCache.set(cacheKey, responseText);
    return responseText;
  }
}

module.exports = new AICoachService();