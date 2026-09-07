-- PaymentProviderConfig: configuration externalisée par commune / canal
CREATE TABLE payment_provider_config (
    id BIGSERIAL PRIMARY KEY,
    provider_code VARCHAR(64) NOT NULL,
    display_name VARCHAR(128),
    commune_id BIGINT,
    channel VARCHAR(32),
    priority INT NOT NULL DEFAULT 0,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sandbox BOOLEAN NOT NULL DEFAULT TRUE,
    base_url_sandbox VARCHAR(512),
    base_url_prod VARCHAR(512),
    credentials_ref VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_payment_provider_config_commune FOREIGN KEY (commune_id) REFERENCES commune(id)
);

CREATE INDEX idx_payment_provider_config_code ON payment_provider_config(provider_code);

-- PaymentQRCode: QR code lié à une CollectionOrder
CREATE TABLE payment_qr_code (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(256) NOT NULL UNIQUE,
    collection_order_id BIGINT NOT NULL,
    payload TEXT,
    generated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP,
    used_at TIMESTAMP,
    actif BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_payment_qr_code_collection_order FOREIGN KEY (collection_order_id) REFERENCES collection_order(id)
);

CREATE INDEX idx_payment_qr_code_token ON payment_qr_code(token);
