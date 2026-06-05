const { DataTypes } = require('sequelize');
const sequelize     = require('../config/db.config');
const bcrypt        = require('bcryptjs');

const SALT_ROUNDS = 10;

const User = sequelize.define('User', {
  email: {
    type:      DataTypes.STRING,
    unique:    true,
    allowNull: false,
    validate:  { isEmail: true },
  },
  password: {
    type:      DataTypes.STRING,
    allowNull: true, // null for Google users
  },
  googleId: {
    type:      DataTypes.STRING,
    unique:    true,
    allowNull: true,
  },
  displayName: {
    type:  DataTypes.STRING,
    field: 'display_name',
  },
  isVerified: {
    type:         DataTypes.BOOLEAN,
    defaultValue: false,
  },
  xp: {
    type:         DataTypes.INTEGER,
    defaultValue: 0,
  },
  level: {
    type:         DataTypes.INTEGER,
    defaultValue: 1,
  },
  resetPasswordToken: {
    type:      DataTypes.STRING,
    allowNull: true,
  },
  resetPasswordExpires: {
    type:      DataTypes.DATE,
    allowNull: true,
  },
}, {
  hooks: {
    // Hash on register
    beforeCreate: async (user) => {
      if (user.password) {
        user.password = await bcrypt.hash(user.password, SALT_ROUNDS);
      }
    },
    // Hash on password reset / update
    beforeUpdate: async (user) => {
      if (user.changed('password') && user.password) {
        user.password = await bcrypt.hash(user.password, SALT_ROUNDS);
      }
    },
  },
});

// Instance method for password verification
User.prototype.comparePassword = async function (candidatePassword) {
  if (!this.password) return false; // Google users have no password
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = User;