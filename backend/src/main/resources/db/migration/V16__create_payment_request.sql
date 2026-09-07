-- PaymentRequest (RTP - Request to Pay)
CREATE TABLE payment_request (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128) NOT NULL UNIQUE,
    collection_order_id BIGINT NOT NULL,
    taxpayer_id BIGINT NOT NULL,
    amount NUMERIC(19,2) NOT NULL,
    currency VARCHAR(8) NOT NULL DEFAULT 'XOF',
    provider VARCHAR(32) NOT NULL,
    provider_request_id VARCHAR(128),
    status VARCHAR(32) NOT NULL DEFAULT 'RTP_CREATED',
    expires_at TIMESTAMP,
    sent_at TIMESTAMP,
    accepted_at TIMESTAMP,
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_payment_request_collection_order FOREIGN KEY (collection_order_id) REFERENCES collection_order(id),
    CONSTRAINT fk_payment_request_taxpayer FOREIGN KEY (taxpayer_id) REFERENCES contribuable(id)
);

CREATE INDEX idx_payment_request_reference ON payment_request(reference);
CREATE INDEX idx_payment_request_collection_order ON payment_request(collection_order_id);
