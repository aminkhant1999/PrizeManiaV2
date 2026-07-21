const db = require('../config/db');

async function listActive() {
  const [rows] = await db.execute('SELECT * FROM prizes WHERE is_active = 1 ORDER BY display_order, id');
  return rows;
}
async function listAll() { const [rows] = await db.execute('SELECT * FROM prizes ORDER BY display_order, id'); return rows; }
async function findById(id) { const [rows] = await db.execute('SELECT * FROM prizes WHERE id = ? LIMIT 1', [id]); return rows[0] || null; }
async function create(data) {
  const [result] = await db.execute('INSERT INTO prizes (name, description, image_path, display_order, is_active) VALUES (?, ?, ?, ?, ?)', [data.name, data.description, data.imagePath, data.displayOrder, data.isActive]);
  return result.insertId;
}
async function update(id, data) {
  return db.execute('UPDATE prizes SET name=?, description=?, image_path=?, display_order=?, is_active=? WHERE id=?', [data.name, data.description, data.imagePath, data.displayOrder, data.isActive, id]);
}
async function remove(id) { return db.execute('UPDATE prizes SET is_active = 0 WHERE id = ?', [id]); }
module.exports = { listActive, listAll, findById, create, update, remove };
