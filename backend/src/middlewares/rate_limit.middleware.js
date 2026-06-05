const rateLimit = require('express-rate-limit');

exports.aiRateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 20, // Limit each user to 20 requests per window
    message: { message: "The coach is resting. Please try again in 15 minutes." }
});