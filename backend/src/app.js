const express    = require('express');
const cors       = require('cors');
const helmet     = require('helmet');

const sequelize      = require('./config/db.config');
const errorHandler    = require('./middlewares/error.middleware');
const authRoutes      = require('./routes/auth.routes');
const exerciseRoutes  = require('./routes/exercise.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const trackingRoutes  = require('./routes/tracking.routes');
const workoutRoutes   = require('./routes/workout.routes');
const gymRoutes       = require('./routes/gym.routes');
const stepsRoutes     = require('./routes/steps.routes');
const aiCoachRoutes   = require('./routes/ai_coach.routes');

const app = express();

// ─── Security Middleware ───────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: '*', // 🔴 in production, restrict to your domain
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// ─── Health Check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date().toISOString() });
});

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/api/auth',      authRoutes);
app.use('/api/exercises', exerciseRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/tracking',  trackingRoutes);
app.use('/api/workout',   workoutRoutes);
app.use('/api/gyms',      gymRoutes);
app.use('/api/steps',     stepsRoutes);
app.use('/api/coach',     aiCoachRoutes);

// ─── 404 Handler ──────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.url} not found` });
});

// ─── Error Handler (must be last) ─────────────────────────────────────────────
app.use(errorHandler);

// ─── DB Sync + Start Server ───────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;

sequelize.sync({ alter: true }) // alter:true updates columns without dropping data
  .then(() => {
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ Failed to sync database:', err.message);
    process.exit(1);
  });

module.exports = app;