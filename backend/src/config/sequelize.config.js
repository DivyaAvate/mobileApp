require('dotenv').config();

const config = {
  username: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',          // empty string or env variable for password
  database: process.env.DB_NAME || 'gymbuddy_db',
  host:     process.env.DB_HOST || '127.0.0.1', // 127.0.0.1 instead of localhost
  port:     Number(process.env.DB_PORT) || 3307,
  dialect:  'mysql',
  dialectOptions: { charset: 'utf8mb4' },
};

module.exports = {
  development: config,
  production:  config,
};