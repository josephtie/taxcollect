package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "payment_attempt")
public class PaymentAttempt extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "collection_order_id", nullable = false)
    private Long collectionOrderId;

    @Column(name = "attempt_number", nullable = false)
    private int attemptNumber;

    @Column(nullable = false, length = 32)
    private String provider;

    @Column(name = "provider_transaction_id", length = 128)
    private String providerTransactionId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private StatutTransaction status;

    @Column(name = "failure_reason", length = 255)
    private String failureReason;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getCollectionOrderId() { return collectionOrderId; }
    public void setCollectionOrderId(Long collectionOrderId) { this.collectionOrderId = collectionOrderId; }
    public int getAttemptNumber() { return attemptNumber; }
    public void setAttemptNumber(int attemptNumber) { this.attemptNumber = attemptNumber; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getProviderTransactionId() { return providerTransactionId; }
    public void setProviderTransactionId(String providerTransactionId) { this.providerTransactionId = providerTransactionId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public StatutTransaction getStatus() { return status; }
    public void setStatus(StatutTransaction status) { this.status = status; }
    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }
}
