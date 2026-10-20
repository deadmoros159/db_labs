DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS clients CASCADE;

-- 1. Клиенты банка
CREATE TABLE clients (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_series VARCHAR(4) NOT NULL,
    passport_number VARCHAR(6) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT uq_clients_phone UNIQUE (phone),
    CONSTRAINT uq_clients_email UNIQUE (email),

    CONSTRAINT uq_clients_passport UNIQUE (passport_series, passport_number),

    CONSTRAINT chk_client_adult CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years'),
    CONSTRAINT chk_client_passport_series CHECK (passport_series ~ '^[0-9]{4}$'),
    CONSTRAINT chk_client_passport_number CHECK (passport_number ~ '^[0-9]{6}$')
);

-- 2. Счета клиентов
CREATE TABLE accounts (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_accounts_client FOREIGN KEY (client_id) 
        REFERENCES clients(id) ON DELETE RESTRICT,
    
    CONSTRAINT uq_accounts_number UNIQUE (account_number),

    CONSTRAINT chk_accounts_currency CHECK (currency IN ('RUB', 'USD', 'EUR', 'CNY')),
    CONSTRAINT chk_accounts_status CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    CONSTRAINT chk_accounts_balance CHECK (balance >= 0.00)
);

-- 3. Банковские карты
CREATE TABLE cards (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL,
    card_number VARCHAR(16) NOT NULL,
    cardholder_name VARCHAR(100) NOT NULL,
    expiration_date DATE NOT NULL,
    payment_system VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_cards_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE,
        
    CONSTRAINT uq_cards_number UNIQUE (card_number),

    CONSTRAINT chk_cards_number_format CHECK (card_number ~ '^[0-9]{16}$'),
    CONSTRAINT chk_cards_payment_system CHECK (payment_system IN ('MIR', 'VISA', 'MASTERCARD')),
    CONSTRAINT chk_cards_status CHECK (status IN ('ACTIVE', 'BLOCKED', 'EXPIRED'))
);

-- 4. Транзакции
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    from_account_id BIGINT,
    to_account_id BIGINT,
    amount NUMERIC(15, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_trans_from_account FOREIGN KEY (from_account_id) 
        REFERENCES accounts(id) ON DELETE SET NULL,
    CONSTRAINT fk_trans_to_account FOREIGN KEY (to_account_id) 
        REFERENCES accounts(id) ON DELETE SET NULL,

    CONSTRAINT chk_transactions_amount CHECK (amount > 0.00),
    CONSTRAINT chk_transactions_status CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')),

    CONSTRAINT chk_transactions_accounts_distinct CHECK (
        (from_account_id IS NOT NULL OR to_account_id IS NOT NULL) AND
        (from_account_id IS DISTINCT FROM to_account_id)
    )
);

-- 5. Кредиты
CREATE TABLE loans (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    principal_amount NUMERIC(15, 2) NOT NULL,
    interest_rate NUMERIC(5, 2) NOT NULL,
    remaining_amount NUMERIC(15, 2) NOT NULL,
    term_months INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_loans_client FOREIGN KEY (client_id) 
        REFERENCES clients(id) ON DELETE RESTRICT,

    CONSTRAINT chk_loans_principal CHECK (principal_amount > 0.00),
    CONSTRAINT chk_loans_rate CHECK (interest_rate >= 0.00 AND interest_rate <= 100.00),
    CONSTRAINT chk_loans_term CHECK (term_months > 0),
    CONSTRAINT chk_loans_status CHECK (status IN ('ACTIVE', 'PAID_OFF', 'DEFAULTED')),


    CONSTRAINT chk_loans_remaining_bounds CHECK (
        remaining_amount >= 0.00 AND remaining_amount <= principal_amount
    )
);