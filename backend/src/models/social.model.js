const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Friend = sequelize.define('Friend', {
    user_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    friend_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    status: { type: DataTypes.ENUM('pending', 'accepted'), defaultValue: 'pending' }
}, { timestamps: true });

module.exports = Friend;