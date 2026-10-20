-- Моковые значения
-- 1. Клиенты
INSERT INTO clients (first_name, last_name, passport_series, passport_number, phone, email, birth_date)
VALUES 
('Иван', 'Иванов', '4510', '123456', '+79991112233', 'ivanov@example.com', '1995-04-12'),
('Анна', 'Смирнова', '4512', '654321', '+79992223344', 'smirnova@example.com', '2001-08-23'),
('Петр', 'Сидоров', '4508', '789012', '+79993334455', 'sidorov@example.com', '1988-11-05');

-- 2. Счета
INSERT INTO accounts (client_id, account_number, currency, balance, status)
VALUES
(1, '40817810000000000001', 'RUB', 150000.00, 'ACTIVE'),
(1, '40817840000000000002', 'USD', 2500.00, 'ACTIVE'),
(2, '40817810000000000003', 'RUB', 42000.50, 'ACTIVE'),
(3, '40817810000000000004', 'RUB', 500.00, 'FROZEN');

-- 3. Карты
INSERT INTO cards (account_id, card_number, cardholder_name, expiration_date, payment_system, status)
VALUES
(1, '2200123456789010', 'IVAN IVANOV', '2028-12-31', 'MIR', 'ACTIVE'),
(1, '2200123456789011', 'IVAN IVANOV', '2027-06-30', 'MIR', 'ACTIVE'),
(3, '2200987654321099', 'ANNA SMIRNOVA', '2029-01-31', 'MIR', 'ACTIVE');

-- 4. Транзакции
INSERT INTO transactions (from_account_id, to_account_id, amount, status)
VALUES
(1, 3, 5000.00, 'COMPLETED'),
(3, 1, 1500.00, 'COMPLETED'),
(NULL, 1, 20000.00, 'COMPLETED'),
(3, NULL, 3000.00, 'COMPLETED');

-- 5. Кредиты
INSERT INTO loans (client_id, principal_amount, interest_rate, remaining_amount, term_months, status, start_date)
VALUES
(1, 500000.00, 14.50, 320000.00, 36, 'ACTIVE', '2025-01-15'),
(2, 100000.00, 19.90, 100000.00, 12, 'ACTIVE', '2026-03-01');