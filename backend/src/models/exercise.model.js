const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Exercise = sequelize.define('Exercise', {
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT },
    muscleGroup: { 
        type: DataTypes.ENUM('chest', 'back', 'legs', 'shoulders', 'arms', 'core', 'full_body', 'cardio'),
        allowNull: false 
    },
    equipment: { 
        type: DataTypes.ENUM('none', 'dumbbell', 'barbell', 'kettlebell', 'machine', 'cable', 'bands'),
        allowNull: false 
    },
    videoUrl: { type: DataTypes.STRING }, // YouTube Link
}, { timestamps: true });

module.exports = Exercise;