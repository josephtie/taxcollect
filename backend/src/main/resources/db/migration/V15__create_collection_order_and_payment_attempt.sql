-- CollectionOrder: entité intermédiaire entre TaxeCollect et le paiement
CREATE TABLE collection_order (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128) NOT NULL UNIQUE,
    taxe_collect_id BIGINT NOT NULL,
    contribuable_id BIGINT NOT NULL,
    amount NUMERIC(19,2) NOT NULL,
    currency VARCHAR(8) NOT NULL DEFAULT 'XOF',
    channel VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_collection_order_taxecollect FOREIGN KEY (taxe_collect_id) REFERENCES taxecollect(id),
    CONSTRAINT fk_collection_order_contribuable FOREIGN KEY (contribuable_id) REFERENCES contribuable(id)
);

CREATE INDEX idx_collection_order_reference ON collection_order(reference);
CREATE INDEX idx_collection_order_taxecollect ON collection_order(taxe_collect_id);

-- PaymentAttempt: tentatives de paiement sur une CollectionOrder
CREATE TABLE payment_attempt (
    id BIGSERIAL PRIMARY KEY,
    collection_order_id BIGINT NOT NULL,
    attempt_number INT NOT NULL,
    provider VARCHAR(32) NOT NULL,
    provider_transaction_id VARCHAR(128),
    amount NUMERIC(19,2) NOT NULL,
    status VARCHAR(32) NOT NULL,
    failure_reason VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_payment_attempt_collection_order FOREIGN KEY (collection_order_id) REFERENCES collection_order(id)
);

CREATE INDEX idx_payment_attempt_collection_order ON payment_attempt(collection_order_id);

-- Ajouter la FK de transaction vers collection_order (la table existe maintenant)
ALTER TABLE transaction ADD CONSTRAINT fk_transaction_collection_order
    FOREIGN KEY (collection_order_id) REFERENCES collection_order(id);
