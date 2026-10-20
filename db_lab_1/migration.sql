CREATE TABLE IF NOT EXISTS branches (
    id BIGSERIAL PRIMARY KEY,
    branch_code VARCHAR(10) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    CONSTRAINT uq_branches_code UNIQUE (branch_code)
);

INSERT INTO branches (branch_code, address, city)
VALUES ('HQ-01', 'Ленинградский проспект, 40', 'Москва')
ON CONFLICT (branch_code) DO NOTHING;

ALTER TABLE accounts 
    ADD COLUMN IF NOT EXISTS branch_id BIGINT,
    ADD COLUMN IF NOT EXISTS overdraft_limit NUMERIC(15, 2) NOT NULL DEFAULT 0.00;

UPDATE accounts 
SET branch_id = (SELECT id FROM branches WHERE branch_code = 'HQ-01')
WHERE branch_id IS NULL;

ALTER TABLE accounts 
    ALTER COLUMN branch_id SET NOT NULL,
    ADD CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) 
        REFERENCES branches(id) ON DELETE RESTRICT;

ALTER TABLE accounts 
    ADD CONSTRAINT chk_accounts_overdraft CHECK (overdraft_limit >= 0.00);

ALTER TABLE loans 
    ADD COLUMN IF NOT EXISTS loan_type VARCHAR(30) NOT NULL DEFAULT 'CONSUMER';

ALTER TABLE loans 
    ADD CONSTRAINT chk_loans_type CHECK (loan_type IN ('CONSUMER', 'MORTGAGE', 'CAR_LOAN', 'BUSINESS'));