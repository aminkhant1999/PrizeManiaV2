const db = require('../config/db');

async function findByEmail(email, connection = db) {
  const [rows] = await connection.execute('SELECT * FROM users WHERE email = ? LIMIT 1', [email]);
  return rows[0] || null;
}
async function findById(id, connection = db) {
  const [rows] = await connection.execute('SELECT id, name, email, role, wallet_balance, created_at FROM users WHERE id = ? LIMIT 1', [id]);
  return rows[0] || null;
}
async function create({ name, email, passwordHash }, connection = db) {
  const [result] = await connection.execute(
    'INSERT INTO users (name, email, password_hash, role, wallet_balance) VALUES (?, ?, ?, \'user\', 100.00)',
    [name, email, passwordHash]
  );
  return result.insertId;
}
async function listAll() {
  const [rows] = await db.execute('SELECT id, name, email, role, wallet_balance, created_at FROM users ORDER BY created_at DESC');
  return rows;
}
async function countAll() { const [[row]] = await db.execute('SELECT COUNT(*) AS count FROM users'); return row.count; }

module.exports = { findByEmail, findById, create, listAll, countAll };
