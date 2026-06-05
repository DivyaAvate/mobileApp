const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const WorkoutPlan = sequelize.define('WorkoutPlan', {
    userId: { type: DataTypes.INTEGER, allowNull: false },
    goal: { type: DataTypes.ENUM('fat_loss', 'muscle_gain', 'strength', 'general_fitness'), allowNull: false },
    experience: { type: DataTypes.ENUM('beginner', 'intermediate', 'advanced'), allowNull: false },
    daysPerWeek: { type: DataTypes.INTEGER, allowNull: false },
    isActive: { type: DataTypes.BOOLEAN, defaultValue: true }
});

const WorkoutDay = sequelize.define('WorkoutDay', {
    planId: { type: DataTypes.INTEGER, allowNull: false },
    dayName: { type: DataTypes.STRING, allowNull: false }, // e.g., "Push", "Upper"
    dayNumber: { type: DataTypes.INTEGER, allowNull: false }
});

const WorkoutExercise = sequelize.define('WorkoutExercise', {
    dayId: { type: DataTypes.INTEGER, allowNull: false },
    exerciseId: { type: DataTypes.INTEGER, allowNull: false },
    sets: { type: DataTypes.INTEGER, allowNull: false },
    reps: { type: DataTypes.STRING, allowNull: false },
    order: { type: DataTypes.INTEGER, allowNull: false }
});

// Relationships
WorkoutPlan.hasMany(WorkoutDay, { as: 'days', foreignKey: 'planId' });
WorkoutDay.hasMany(WorkoutExercise, { as: 'exercises', foreignKey: 'dayId' });
WorkoutExercise.belongsTo(require('./exercise.model'), { foreignKey: 'exerciseId', as: 'details' });

module.exports = { WorkoutPlan, WorkoutDay, WorkoutExercise };