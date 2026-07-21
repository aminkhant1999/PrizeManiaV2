const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');

dotenv.config({ quiet: true });

async function setupDatabase() {
  const sql = fs.readFileSync(
    path.join(__dirname, '..', 'database', 'bootstrap.sql'),
    'utf8'
  );

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    charset: 'utf8mb4',
    multipleStatements: true
  });

  try {
    await connection.query(sql);
    console.log(`Database schema is ready in ${process.env.DB_NAME}.`);
  } finally {
    await connection.end();
  }
}

setupDatabase().catch((error) => {
  console.error('Database setup failed:', error.message);
  process.exit(1);
});
