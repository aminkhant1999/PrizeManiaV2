const db=require('../config/db');
async function listForUser(userId){const [r]=await db.execute(`SELECT p.*,d.name draw_name FROM purchases p JOIN draws d ON d.id=p.draw_id WHERE p.user_id=? ORDER BY p.created_at DESC`,[userId]);return r;}
async function listAll(){const [r]=await db.execute(`SELECT p.*,u.name user_name,u.email,d.name draw_name FROM purchases p JOIN users u ON u.id=p.user_id JOIN draws d ON d.id=p.draw_id ORDER BY p.created_at DESC`);return r;}
async function countAll(){const [[r]]=await db.execute('SELECT COUNT(*) count FROM purchases');return r.count;}
module.exports={listForUser,listAll,countAll};
