const db = require('../config/db');
const BASE = `SELECT d.*, COUNT(DISTINCT t.id) AS ticket_count, COUNT(DISTINCT w.id) AS winner_count
  FROM draws d LEFT JOIN tickets t ON t.draw_id=d.id LEFT JOIN winners w ON w.draw_id=d.id`;
async function getOpen() { const [r] = await db.execute(`${BASE} WHERE d.status='open' AND d.opens_at<=NOW() AND d.closes_at>NOW() GROUP BY d.id ORDER BY d.draw_date LIMIT 1`); return r[0] || null; }
async function listAll() { const [r] = await db.execute(`${BASE} GROUP BY d.id ORDER BY d.draw_date DESC`); return r; }
async function findById(id, connection = db, lock = false) { const [r] = await connection.execute(`SELECT * FROM draws WHERE id=?${lock ? ' FOR UPDATE' : ''}`, [id]); return r[0] || null; }
async function create(data) { const [r] = await db.execute('INSERT INTO draws (name, draw_date, ticket_price, status, opens_at, closes_at) VALUES (?,?,?,?,?,?)', [data.name,data.drawDate,data.ticketPrice,data.status,data.opensAt,data.closesAt]); return r.insertId; }
async function updateStatus(id, status, connection = db) { return connection.execute('UPDATE draws SET status=?, published_at=IF(?=\'published\',NOW(),published_at) WHERE id=?', [status,status,id]); }
module.exports = { getOpen, listAll, findById, create, updateStatus };
