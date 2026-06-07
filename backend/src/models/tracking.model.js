const { DataTypes } = require('sequelize');
const sequelize     = require('../config/db.config');

// ─── WorkoutLog ───────────────────────────────────────────────────────────────

const WorkoutLog = sequelize.define('WorkoutLog', {
  userId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'user_id',           // ← matches migration column name
  },
  planId: {
    type:      DataTypes.INTEGER,
    allowNull: true,
    field:     'plan_id',
  },
  name: {
    type:      DataTypes.STRING,    // ← was missing, needed by dashboard
    allowNull: true,
  },
  workoutDay: {
    type:      DataTypes.STRING,
    allowNull: true,
    field:     'workout_day',
  },
  startTime: {
    type:         DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field:        'start_time',
  },
  endTime: {
    type:      DataTypes.DATE,
    allowNull: true,
    field:     'end_time',
  },
  durationSec: {
    type:         DataTypes.INTEGER,
    defaultValue: 0,
    field:        'duration_sec',   // ← was missing, needed by tracking
  },
  totalSets: {
    type:         DataTypes.INTEGER,
    defaultValue: 0,
    field:        'total_sets',     // ← was missing
  },
  totalVolume: {
    type:         DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
    field:        'total_volume',
  },
  status: {
    type:         DataTypes.ENUM('active', 'completed', 'skipped'),
    defaultValue: 'active',
  },
  notes: {
    type:      DataTypes.TEXT,
    allowNull: true,
  },
}, {
  underscored: true,  // auto snake_case for createdAt/updatedAt
});

// ─── ExerciseLog ──────────────────────────────────────────────────────────────

const ExerciseLog = sequelize.define('ExerciseLog', {
  workoutLogId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'workout_log_id',
  },
  exerciseId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'exercise_id',
  },
  order: {
    type:         DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  underscored: true,
});

// ─── SetLog ───────────────────────────────────────────────────────────────────

const SetLog = sequelize.define('SetLog', {
  exerciseLogId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'exercise_log_id',
  },
  setNumber: {
    type:         DataTypes.INTEGER,
    defaultValue: 1,
    field:        'set_number',
  },
  weight: {
    type:      DataTypes.DECIMAL(6, 2),
    allowNull: false,
  },
  reps: {
    type:      DataTypes.INTEGER,
    allowNull: false,
  },
  isPR: {
    type:         DataTypes.BOOLEAN,
    defaultValue: false,
    field:        'is_pr',
  },
}, {
  underscored: true,
});

// ─── Associations ─────────────────────────────────────────────────────────────

const Exercise = require('./exercise.model');

WorkoutLog.hasMany(ExerciseLog, { as: 'exercises', foreignKey: 'workout_log_id' });
ExerciseLog.belongsTo(WorkoutLog, { foreignKey: 'workout_log_id' });

ExerciseLog.hasMany(SetLog, { as: 'sets', foreignKey: 'exercise_log_id' });
SetLog.belongsTo(ExerciseLog, { foreignKey: 'exercise_log_id' });

ExerciseLog.belongsTo(Exercise, { foreignKey: 'exercise_id', as: 'exerciseDetails' });
Exercise.hasMany(ExerciseLog,   { foreignKey: 'exercise_id' });

module.exports = { WorkoutLog, ExerciseLog, SetLog };