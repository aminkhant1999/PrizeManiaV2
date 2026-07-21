-- PrizeMania development schema (MySQL 8+)
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
DROP DATABASE IF EXISTS prizemania;
CREATE DATABASE prizemania CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prizemania;

CREATE TABLE users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(150) NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('user','admin') NOT NULL DEFAULT 'user',
 wallet_balance DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT 100.00,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_users_email(email)
) ENGINE=InnoDB;

CREATE TABLE prizes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(120) NOT NULL,
 description VARCHAR(255) NOT NULL,
 image_path VARCHAR(255) NOT NULL,
 display_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
 is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_prizes_active_order(is_active,display_order)
) ENGINE=InnoDB;

CREATE TABLE draws (
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
 CONSTRAINT chk_draw_dates CHECK (closes_at>opens_at),
 CONSTRAINT chk_draw_price CHECK (ticket_price>0)
) ENGINE=InnoDB;

CREATE TABLE purchases (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NOT NULL,
 draw_id INT UNSIGNED NOT NULL,
 quantity SMALLINT UNSIGNED NOT NULL,
 unit_price DECIMAL(10,2) UNSIGNED NOT NULL,
 total_amount DECIMAL(10,2) UNSIGNED NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_purchase_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 CONSTRAINT fk_purchase_draw FOREIGN KEY(draw_id) REFERENCES draws(id) ON DELETE RESTRICT,
 KEY idx_purchase_user_date(user_id,created_at), KEY idx_purchase_draw(draw_id),
 CONSTRAINT chk_purchase_quantity CHECK(quantity>0),
 CONSTRAINT chk_purchase_total CHECK(total_amount=quantity*unit_price)
) ENGINE=InnoDB;

CREATE TABLE tickets (
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
 KEY idx_ticket_draw(draw_id), KEY idx_ticket_user_date(user_id,created_at), KEY idx_ticket_purchase(purchase_id)
) ENGINE=InnoDB;

CREATE TABLE winners (
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
) ENGINE=InnoDB;
SET FOREIGN_KEY_CHECKS=1;
