const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Friend = sequelize.define('Friend', {
    user_id: { type: DataTypes.INTEGER, allowNull: false },
    friend_id: { type: DataTypes.INTEGER, allowNull: false },
    status: { type: DataTypes.ENUM('pending', 'accepted'), defaultValue: 'pending' }
}, { timestamps: true });

module.exports = Friend;