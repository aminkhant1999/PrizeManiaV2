const mysql = require('mysql2/promise');

let pool;

function getConfig() {
  const required = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
  const missing = required.filter((name) => !process.env[name]);
  if (missing.length) throw new Error(`Missing required environment variable(s): ${missing.join(', ')}`);
  return {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    charset: 'utf8mb4',
    namedPlaceholders: true,
    decimalNumbers: true
  };
}

function getPool() {
  if (!pool) pool = mysql.createPool(getConfig());
  return pool;
}

async function execute(...args) { return getPool().execute(...args); }
async function query(...args) { return getPool().query(...args); }
async function getConnection() { return getPool().getConnection(); }
async function initializePool() {
  const connection = await getConnection();
  try { await connection.ping(); } finally { connection.release(); }
  console.log('MySQL database connected successfully.');
}

module.exports = { execute, query, getConnection, initializePool, getPool };
