-- Receipt: reçu officiel
CREATE TABLE receipt (
    id BIGSERIAL PRIMARY KEY,
    receipt_number VARCHAR(128) NOT NULL UNIQUE,
    transaction_id BIGINT NOT NULL,
    taxe_collect_id BIGINT,
    taxpayer_id BIGINT,
    amount NUMERIC(19,2) NOT NULL,
    currency VARCHAR(8) NOT NULL DEFAULT 'XOF',
    provider VARCHAR(32),
    provider_transaction_id VARCHAR(128),
    issued_at TIMESTAMP NOT NULL DEFAULT NOW(),
    pdf_url VARCHAR(512),
    pdf_content TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_receipt_transaction FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    CONSTRAINT fk_receipt_taxecollect FOREIGN KEY (taxe_collect_id) REFERENCES taxecollect(id),
    CONSTRAINT fk_receipt_taxpayer FOREIGN KEY (taxpayer_id) REFERENCES contribuable(id)
);

CREATE INDEX idx_receipt_number ON receipt(receipt_number);
CREATE INDEX idx_receipt_transaction ON receipt(transaction_id);

-- Refund: remboursement
CREATE TABLE refund (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128) NOT NULL UNIQUE,
    transaction_id BIGINT NOT NULL,
    amount NUMERIC(19,2) NOT NULL,
    currency VARCHAR(8) NOT NULL DEFAULT 'XOF',
    provider VARCHAR(32),
    provider_refund_id VARCHAR(128),
    status VARCHAR(32) NOT NULL DEFAULT 'INITIATED',
    reason VARCHAR(512),
    initiated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_refund_transaction FOREIGN KEY (transaction_id) REFERENCES transaction(id)
);

CREATE INDEX idx_refund_reference ON refund(reference);
CREATE INDEX idx_refund_transaction ON refund(transaction_id);
