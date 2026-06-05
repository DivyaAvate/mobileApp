const { DataTypes } = require('sequelize');
const sequelize     = require('../config/db.config');

// ─── Gym ──────────────────────────────────────────────────────────────────────
const Gym = sequelize.define('Gym', {
  name: {
    type:      DataTypes.STRING,
    allowNull: false,
  },
  logoUrl: {
    type:      DataTypes.STRING,
    allowNull: true,
    field:     'logo_url',
  },
  address: {
    type:      DataTypes.STRING,
    allowNull: true,
  },
  city: {
    type:      DataTypes.STRING,
    allowNull: true,
  },
  phone: {
    type:      DataTypes.STRING,
    allowNull: true,
  },
  description: {
    type:      DataTypes.TEXT,
    allowNull: true,
  },
  isActive: {
    type:         DataTypes.BOOLEAN,
    defaultValue: true,
    field:        'is_active',
  },
  ownerUserId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'owner_user_id',
  },
}, { underscored: true });

// ─── GymMembership ────────────────────────────────────────────────────────────
const GymMembership = sequelize.define('GymMembership', {
  userId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'user_id',
  },
  gymId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'gym_id',
  },
  referralCode: {
    type:      DataTypes.STRING(12),
    allowNull: false,
    unique:    true,
    field:     'referral_code',
  },
  role: {
    type:         DataTypes.ENUM('member', 'gym_owner', 'super_admin'),
    defaultValue: 'member',
  },
  joinedAt: {
    type:         DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field:        'joined_at',
  },
}, { underscored: true });

// ─── Offer ────────────────────────────────────────────────────────────────────
const Offer = sequelize.define('Offer', {
  gymId: {
    type:      DataTypes.INTEGER,
    allowNull: false,
    field:     'gym_id',
  },
  title: {
    type:      DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type:      DataTypes.TEXT,
    allowNull: true,
  },
  imageUrl: {
    type:      DataTypes.STRING,
    allowNull: true,
    field:     'image_url',
  },
  type: {
    type:         DataTypes.ENUM('announcement', 'offer', 'event', 'challenge'),
    defaultValue: 'announcement',
  },
  expiresAt: {
    type:      DataTypes.DATE,
    allowNull: true,
    field:     'expires_at',
  },
  isActive: {
    type:         DataTypes.BOOLEAN,
    defaultValue: true,
    field:        'is_active',
  },
}, { underscored: true });

// ─── Associations ─────────────────────────────────────────────────────────────
const User = require('./user.model');

Gym.belongsTo(User,           { foreignKey: 'owner_user_id', as: 'owner' });
User.hasMany(GymMembership,   { foreignKey: 'user_id',       as: 'memberships' });
Gym.hasMany(GymMembership,    { foreignKey: 'gym_id',        as: 'memberships' });
GymMembership.belongsTo(Gym,  { foreignKey: 'gym_id',        as: 'gym' });
GymMembership.belongsTo(User, { foreignKey: 'user_id',       as: 'user' });
Gym.hasMany(Offer,            { foreignKey: 'gym_id',        as: 'offers' });
Offer.belongsTo(Gym,          { foreignKey: 'gym_id',        as: 'gym' });

module.exports = { Gym, GymMembership, Offer };