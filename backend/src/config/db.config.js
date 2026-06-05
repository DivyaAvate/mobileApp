const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  '',                    // empty string for no-password MySQL
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3307,
    dialect: 'mysql',
    logging: false,

    // ── Connection Pool ──────────────────────────────────────
    // Handles multiple simultaneous Flutter users
    pool: {
      max: 10,  // max connections
      min: 2,   // keep 2 alive always
      acquire: 30000, // ms to wait before throwing error
      idle: 10000, // ms before releasing idle connection
    },

    // ── MySQL specific ───────────────────────────────────────
    dialectOptions: {
      charset: 'utf8mb4',        // supports emojis 💪
      decimalNumbers: true,
    },

    define: {
      underscored: true,       // auto snake_case column names
      freezeTableName: false,    // pluralise table names
      timestamps: true,       // createdAt, updatedAt auto-added
    },
  }
);

// ── Test connection on startup ───────────────────────────────
sequelize.authenticate()
  .then(() => console.log('✅ MySQL connected successfully'))
  .catch(err => {
    console.error('❌ MySQL connection failed:', err.message);
    process.exit(1); // crash fast so you know immediately
  });

module.exports = sequelize;