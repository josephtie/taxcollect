-- Reconciliation: rapprochement entre transactions internes et provider
CREATE TABLE reconciliation (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128) NOT NULL UNIQUE,
    transaction_id BIGINT,
    provider_transaction_id VARCHAR(128),
    internal_status VARCHAR(32),
    provider_status VARCHAR(32),
    amount_internal NUMERIC(19,2),
    amount_provider NUMERIC(19,2),
    discrepancy_type VARCHAR(64) NOT NULL DEFAULT 'NONE',
    status VARCHAR(32) NOT NULL DEFAULT 'MATCHED',
    detected_at TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_reconciliation_transaction FOREIGN KEY (transaction_id) REFERENCES transaction(id)
);

CREATE INDEX idx_reconciliation_reference ON reconciliation(reference);

-- Settlement: règlement municipal
CREATE TABLE settlement (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128) NOT NULL UNIQUE,
    reconciliation_id BIGINT NOT NULL,
    commune_id BIGINT NOT NULL,
    amount NUMERIC(19,2) NOT NULL,
    currency VARCHAR(8) NOT NULL DEFAULT 'XOF',
    settled_at TIMESTAMP NOT NULL DEFAULT NOW(),
    reference_bank VARCHAR(128),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_settlement_reconciliation FOREIGN KEY (reconciliation_id) REFERENCES reconciliation(id),
    CONSTRAINT fk_settlement_commune FOREIGN KEY (commune_id) REFERENCES commune(id)
);

CREATE INDEX idx_settlement_reference ON settlement(reference);
CREATE INDEX idx_settlement_reconciliation ON settlement(reconciliation_id);
