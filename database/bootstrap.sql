-- Idempotent startup schema for local and hosted MySQL databases.
-- It operates inside DB_NAME and never creates or drops a database.
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  wallet_balance DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT 100.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_email(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS prizes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  description VARCHAR(255) NOT NULL,
  image_path VARCHAR(255) NOT NULL,
  display_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_prizes_active_order(is_active,display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS draws (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  draw_date DATE NOT NULL,
  ticket_price DECIMAL(10,2) UNSIGNED NOT NULL,
  status ENUM('draft','open','closed','completed','published') NOT NULL DEFAULT 'draft',
  opens_at DATETIME NOT NULL,
  closes_at DATETIME NOT NULL,
  published_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_draws_date(draw_date),
  KEY idx_draws_status_dates(status,opens_at,closes_at),
  CONSTRAINT chk_draw_dates CHECK (closes_at > opens_at),
  CONSTRAINT chk_draw_price CHECK (ticket_price > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS purchases (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  draw_id INT UNSIGNED NOT NULL,
  quantity SMALLINT UNSIGNED NOT NULL,
  unit_price DECIMAL(10,2) UNSIGNED NOT NULL,
  total_amount DECIMAL(10,2) UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_purchase_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT fk_purchase_draw FOREIGN KEY(draw_id) REFERENCES draws(id) ON DELETE RESTRICT,
  KEY idx_purchase_user_date(user_id,created_at),
  KEY idx_purchase_draw(draw_id),
  CONSTRAINT chk_purchase_quantity CHECK(quantity > 0),
  CONSTRAINT chk_purchase_total CHECK(total_amount = quantity * unit_price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS tickets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  draw_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  purchase_id BIGINT UNSIGNED NOT NULL,
  ticket_number VARCHAR(64) NOT NULL,
  purchased_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_ticket_number(ticket_number),
  CONSTRAINT fk_ticket_draw FOREIGN KEY(draw_id) REFERENCES draws(id) ON DELETE RESTRICT,
  CONSTRAINT fk_ticket_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT fk_ticket_purchase FOREIGN KEY(purchase_id) REFERENCES purchases(id) ON DELETE RESTRICT,
  KEY idx_ticket_draw(draw_id),
  KEY idx_ticket_user_date(user_id,created_at),
  KEY idx_ticket_purchase(purchase_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS winners (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  draw_id INT UNSIGNED NOT NULL,
  prize_id INT UNSIGNED NOT NULL,
  ticket_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  selected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_winner_draw FOREIGN KEY(draw_id) REFERENCES draws(id) ON DELETE RESTRICT,
  CONSTRAINT fk_winner_prize FOREIGN KEY(prize_id) REFERENCES prizes(id) ON DELETE RESTRICT,
  CONSTRAINT fk_winner_ticket FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE RESTRICT,
  CONSTRAINT fk_winner_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
  UNIQUE KEY uq_winner_draw_prize(draw_id,prize_id),
  UNIQUE KEY uq_winner_draw_ticket(draw_id,ticket_id),
  KEY idx_winner_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users(name,email,password_hash,role,wallet_balance)
SELECT 'Demo User','user@prizemania.test','$2b$12$rIRGD834uzvJ.jY.B0OMq.rr26fO8ghw9BfvlxIznpjGJlVjoTeeS','user',100.00
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='user@prizemania.test');

INSERT INTO users(name,email,password_hash,role,wallet_balance)
SELECT 'Demo Admin','admin@prizemania.test','$2b$12$DG3YmzPm.DyIwx3flks21uOMnyvwACOps4KMEv35inwYLjxkyG40q','admin',0.00
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='admin@prizemania.test');

INSERT INTO prizes(name,description,image_path,display_order,is_active)
SELECT 'iPhone 17 Pro Max','Grand prize','/images/iphone17promax.png',1,TRUE
WHERE NOT EXISTS (SELECT 1 FROM prizes WHERE name='iPhone 17 Pro Max');

INSERT INTO prizes(name,description,image_path,display_order,is_active)
SELECT 'Apple Watch Ultra','Second prize','/images/applewatch.jpeg',2,TRUE
WHERE NOT EXISTS (SELECT 1 FROM prizes WHERE name='Apple Watch Ultra');

INSERT INTO prizes(name,description,image_path,display_order,is_active)
SELECT 'PlayStation 5','Third prize','/images/ps5.jpg',3,TRUE
WHERE NOT EXISTS (SELECT 1 FROM prizes WHERE name='PlayStation 5');

INSERT INTO prizes(name,description,image_path,display_order,is_active)
SELECT 'AirPods Pro 3','Fourth prize','/images/airpodsPro3.webp',4,TRUE
WHERE NOT EXISTS (SELECT 1 FROM prizes WHERE name='AirPods Pro 3');

INSERT INTO draws(name,draw_date,ticket_price,status,opens_at,closes_at)
SELECT 'July 2026 Draw','2026-07-31',10.00,'open','2026-07-01 00:00:00','2026-08-01 00:00:00'
WHERE NOT EXISTS (SELECT 1 FROM draws WHERE draw_date='2026-07-31');

-- Published sample results from the previous month. Every insert is guarded so
-- repeated application starts preserve existing data without creating copies.
INSERT INTO users(name,email,password_hash,role,wallet_balance)
SELECT 'Bob Shopper','bob@test.local','$2b$12$LmfZG5T6wYAQnH6aOQZBfOqpaR1x8QvI1Zn5MNj9zdAtzq3wQCw6e','user',150.00
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='bob@test.local');

INSERT INTO draws(name,draw_date,ticket_price,status,opens_at,closes_at,published_at)
SELECT 'June 2026 Draw','2026-06-30',5.00,'published','2026-06-01 00:00:00','2026-07-01 00:00:00','2026-07-01 12:00:00'
WHERE NOT EXISTS (SELECT 1 FROM draws WHERE draw_date='2026-06-30');

UPDATE draws
SET status='published', published_at=COALESCE(published_at,'2026-07-01 12:00:00')
WHERE draw_date='2026-06-30';

INSERT INTO purchases(user_id,draw_id,quantity,unit_price,total_amount)
SELECT u.id,d.id,4,5.00,20.00
FROM users u JOIN draws d ON d.draw_date='2026-06-30'
WHERE u.email='bob@test.local'
  AND NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number='PM-JUN26-0001');

INSERT INTO tickets(draw_id,user_id,purchase_id,ticket_number)
SELECT d.id,u.id,p.id,'PM-JUN26-0001'
FROM users u
JOIN draws d ON d.draw_date='2026-06-30'
JOIN purchases p ON p.user_id=u.id AND p.draw_id=d.id
WHERE u.email='bob@test.local'
  AND NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number='PM-JUN26-0001')
ORDER BY p.id DESC LIMIT 1;

INSERT INTO tickets(draw_id,user_id,purchase_id,ticket_number)
SELECT d.id,u.id,p.id,'PM-JUN26-0002'
FROM users u
JOIN draws d ON d.draw_date='2026-06-30'
JOIN purchases p ON p.user_id=u.id AND p.draw_id=d.id
WHERE u.email='bob@test.local'
  AND NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number='PM-JUN26-0002')
ORDER BY p.id DESC LIMIT 1;

INSERT INTO tickets(draw_id,user_id,purchase_id,ticket_number)
SELECT d.id,u.id,p.id,'PM-JUN26-0003'
FROM users u
JOIN draws d ON d.draw_date='2026-06-30'
JOIN purchases p ON p.user_id=u.id AND p.draw_id=d.id
WHERE u.email='bob@test.local'
  AND NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number='PM-JUN26-0003')
ORDER BY p.id DESC LIMIT 1;

INSERT INTO tickets(draw_id,user_id,purchase_id,ticket_number)
SELECT d.id,u.id,p.id,'PM-JUN26-0004'
FROM users u
JOIN draws d ON d.draw_date='2026-06-30'
JOIN purchases p ON p.user_id=u.id AND p.draw_id=d.id
WHERE u.email='bob@test.local'
  AND NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number='PM-JUN26-0004')
ORDER BY p.id DESC LIMIT 1;

INSERT INTO winners(draw_id,prize_id,ticket_id,user_id)
SELECT d.id,p.id,t.id,u.id
FROM draws d
JOIN prizes p ON p.name='iPhone 17 Pro Max'
JOIN tickets t ON t.ticket_number='PM-JUN26-0001'
JOIN users u ON u.email='bob@test.local'
WHERE d.draw_date='2026-06-30'
  AND NOT EXISTS (SELECT 1 FROM winners w WHERE w.draw_id=d.id AND w.prize_id=p.id);

INSERT INTO winners(draw_id,prize_id,ticket_id,user_id)
SELECT d.id,p.id,t.id,u.id
FROM draws d
JOIN prizes p ON p.name='Apple Watch Ultra'
JOIN tickets t ON t.ticket_number='PM-JUN26-0002'
JOIN users u ON u.email='bob@test.local'
WHERE d.draw_date='2026-06-30'
  AND NOT EXISTS (SELECT 1 FROM winners w WHERE w.draw_id=d.id AND w.prize_id=p.id);

INSERT INTO winners(draw_id,prize_id,ticket_id,user_id)
SELECT d.id,p.id,t.id,u.id
FROM draws d
JOIN prizes p ON p.name='PlayStation 5'
JOIN tickets t ON t.ticket_number='PM-JUN26-0003'
JOIN users u ON u.email='bob@test.local'
WHERE d.draw_date='2026-06-30'
  AND NOT EXISTS (SELECT 1 FROM winners w WHERE w.draw_id=d.id AND w.prize_id=p.id);

INSERT INTO winners(draw_id,prize_id,ticket_id,user_id)
SELECT d.id,p.id,t.id,u.id
FROM draws d
JOIN prizes p ON p.name='AirPods Pro 3'
JOIN tickets t ON t.ticket_number='PM-JUN26-0004'
JOIN users u ON u.email='bob@test.local'
WHERE d.draw_date='2026-06-30'
  AND NOT EXISTS (SELECT 1 FROM winners w WHERE w.draw_id=d.id AND w.prize_id=p.id);
