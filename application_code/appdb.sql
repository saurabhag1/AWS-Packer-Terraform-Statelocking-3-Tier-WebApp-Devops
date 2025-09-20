CREATE DATABASE IF NOT EXISTS webappdb;
USE webappdb;
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));
INSERT IGNORE INTO transactions (amount,description) VALUES
('400','groceries');