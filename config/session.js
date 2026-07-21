const session = require('express-session');
const MySQLStoreFactory = require('express-mysql-session');
const db = require('./db');

function createSessionMiddleware({ useMemoryStore = false } = {}) {
  const secret = process.env.SESSION_SECRET;
  if (!secret || secret.length < 32) {
    if (process.env.NODE_ENV === 'production') throw new Error('SESSION_SECRET must contain at least 32 characters');
    console.warn('Using a development-only session secret. Set SESSION_SECRET in .env.');
  }
  const options = {
    name: 'prizemania.sid',
    secret: secret || 'development-only-change-this-secret-now',
    resave: false,
    saveUninitialized: false,
    rolling: true,
    cookie: {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      maxAge: 1000 * 60 * 60 * 4
    }
  };
  if (!useMemoryStore) {
    const MySQLStore = MySQLStoreFactory(session);
    options.store = new MySQLStore({ createDatabaseTable: true, schema: { tableName: 'sessions' } }, db.getPool());
  }
  return session(options);
}

module.exports = { createSessionMiddleware };
