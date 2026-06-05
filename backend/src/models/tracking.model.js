const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const WorkoutLog = sequelize.define('WorkoutLog', {
    userId: { type: DataTypes.INTEGER, allowNull: false },
    planId: { type: DataTypes.INTEGER, allowNull: true },
    startTime: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    endTime: { type: DataTypes.DATE },
    totalVolume: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    status: { type: DataTypes.ENUM('active', 'completed'), defaultValue: 'active' },
    notes: { type: DataTypes.TEXT }
});

const ExerciseLog = sequelize.define('ExerciseLog', {
    workoutLogId: { type: DataTypes.INTEGER, allowNull: false },
    exerciseId: { type: DataTypes.INTEGER, allowNull: false },
    order: { type: DataTypes.INTEGER }
});

const SetLog = sequelize.define('SetLog', {
    exerciseLogId: { type: DataTypes.INTEGER, allowNull: false },
    weight: { type: DataTypes.DECIMAL(6, 2), allowNull: false },
    reps: { type: DataTypes.INTEGER, allowNull: false },
    isPR: { type: DataTypes.BOOLEAN, defaultValue: false }
});

// Relationships
WorkoutLog.hasMany(ExerciseLog, { as: 'exercises', foreignKey: 'workoutLogId' });
ExerciseLog.hasMany(SetLog, { as: 'sets', foreignKey: 'exerciseLogId' });
ExerciseLog.belongsTo(require('./exercise.model'), { foreignKey: 'exerciseId', as: 'exerciseDetails' });

module.exports = { WorkoutLog, ExerciseLog, SetLog };