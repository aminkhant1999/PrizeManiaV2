USE prizemania;
-- Development-only accounts. Passwords are bcrypt hashes; see README for credentials.
INSERT INTO users(name,email,password_hash,role,wallet_balance) VALUES
('Demo User','user@prizemania.test','$2b$12$rIRGD834uzvJ.jY.B0OMq.rr26fO8ghw9BfvlxIznpjGJlVjoTeeS','user',100.00),
('Demo Admin','admin@prizemania.test','$2b$12$DG3YmzPm.DyIwx3flks21uOMnyvwACOps4KMEv35inwYLjxkyG40q','admin',0.00);

INSERT INTO prizes(name,description,image_path,display_order,is_active) VALUES
('iPhone 17 Pro Max','Grand prize','/images/iphone17promax.png',1,TRUE),
('Apple Watch Ultra','Second prize','/images/applewatch.jpeg',2,TRUE),
('PlayStation 5','Third prize','/images/ps5.jpg',3,TRUE),
('AirPods Pro 3','Fourth prize','/images/airpodsPro3.webp',4,TRUE);

INSERT INTO draws(name,draw_date,ticket_price,status,opens_at,closes_at) VALUES
('July 2026 Draw','2026-07-31',10.00,'open','2026-07-01 00:00:00','2026-08-01 00:00:00');
