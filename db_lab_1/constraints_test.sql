-- ТЕСТ 1: Нарушение составного UNIQUE ограничения uq_clients_passport.
-- Попытка добавить клиента с уже зарегистрированной серией и номером паспорта.
INSERT INTO clients (first_name, last_name, passport_series, passport_number, phone, email, birth_date)
VALUES ('Сергей', 'Павлов', '4510', '123456', '+79990001122', 'pavlov@example.com', '1992-05-10');

-- ТЕСТ 2: Нарушение CHECK ограничения chk_client_adult.
-- Попытка зарегистрировать клиента моложе 18 лет.
INSERT INTO clients (first_name, last_name, passport_series, passport_number, phone, email, birth_date)
VALUES ('Несовершеннолетний', 'Клиент', '4515', '999999', '+79998887766', 'teen@example.com', CURRENT_DATE - INTERVAL '16 years');

-- ТЕСТ 3: Нарушение CHECK ограничения chk_accounts_balance.
-- Баланс счета не может быть отрицательным.
INSERT INTO accounts (client_id, account_number, currency, balance, status)
VALUES (1, '40817810000000000999', 'RUB', -100.00, 'ACTIVE');

-- ТЕСТ 4: Нарушение составного CHECK ограничения chk_transactions_accounts_distinct.
-- Попытка выполнить перевод со счета на этот же самый счет.
INSERT INTO transactions (from_account_id, to_account_id, amount, status)
VALUES (1, 1, 1000.00, 'COMPLETED');

-- ТЕСТ 5: Нарушение составного CHECK ограничения chk_loans_remaining_bounds.
-- Остаток задолженности не может превышать тело кредита.
INSERT INTO loans (client_id, principal_amount, interest_rate, remaining_amount, term_months, status)
VALUES (3, 200000.00, 15.00, 250000.00, 24, 'ACTIVE');

-- ТЕСТ 6: Нарушение FK ограничения при попытке удалить клиента с активными счетами.
DELETE FROM clients WHERE id = 1;