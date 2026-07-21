const db = require('../config/db');
async function listForUser(userId) { const [r] = await db.execute(`SELECT t.*, d.name draw_name, d.status draw_status FROM tickets t JOIN draws d ON d.id=t.draw_id WHERE t.user_id=? ORDER BY t.created_at DESC`,[userId]); return r; }
async function listAll() { const [r] = await db.execute(`SELECT t.*,u.name user_name,u.email,d.name draw_name FROM tickets t JOIN users u ON u.id=t.user_id JOIN draws d ON d.id=t.draw_id ORDER BY t.created_at DESC`); return r; }
async function eligibleForDraw(drawId, connection = db) { const [r] = await connection.execute('SELECT id,user_id,ticket_number FROM tickets WHERE draw_id=? ORDER BY id FOR UPDATE',[drawId]); return r; }
async function countAll() { const [[r]]=await db.execute('SELECT COUNT(*) count FROM tickets'); return r.count; }
module.exports={listForUser,listAll,eligibleForDraw,countAll};
