-- Étendre Transaction pour le module de paiement
ALTER TABLE transaction ADD COLUMN transaction_reference VARCHAR(64);
ALTER TABLE transaction ADD COLUMN provider VARCHAR(32);
ALTER TABLE transaction ADD COLUMN provider_transaction_id VARCHAR(128);
ALTER TABLE transaction ADD COLUMN provider_request_id VARCHAR(128);
ALTER TABLE transaction ADD COLUMN currency VARCHAR(8) DEFAULT 'XOF';
ALTER TABLE transaction ADD COLUMN payment_method VARCHAR(32);
ALTER TABLE transaction ADD COLUMN initiated_at TIMESTAMP;
ALTER TABLE transaction ADD COLUMN completed_at TIMESTAMP;
ALTER TABLE transaction ADD COLUMN failure_reason VARCHAR(255);
ALTER TABLE transaction ADD COLUMN idempotency_key VARCHAR(128);
ALTER TABLE transaction ADD COLUMN collection_order_id BIGINT;

-- Contraintes uniques
ALTER TABLE transaction ADD CONSTRAINT uk_transaction_reference UNIQUE (transaction_reference);
ALTER TABLE transaction ADD CONSTRAINT uk_transaction_idempotency UNIQUE (idempotency_key);

-- Index pour recherche par provider transaction id
CREATE INDEX idx_transaction_provider_tid ON transaction(provider_transaction_id);
