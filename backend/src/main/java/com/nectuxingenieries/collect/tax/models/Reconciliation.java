package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.DiscrepancyType;
import com.nectuxingenieries.collect.tax.models.enums.ReconciliationStatus;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "reconciliation")
public class Reconciliation extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 128)
    private String reference;

    @Column(name = "transaction_id")
    private Long transactionId;

    @Column(name = "provider_transaction_id", length = 128)
    private String providerTransactionId;

    @Column(name = "internal_status", length = 32)
    private String internalStatus;

    @Column(name = "provider_status", length = 32)
    private String providerStatus;

    @Column(name = "amount_internal", precision = 19, scale = 2)
    private BigDecimal amountInternal;

    @Column(name = "amount_provider", precision = 19, scale = 2)
    private BigDecimal amountProvider;

    @Enumerated(EnumType.STRING)
    @Column(name = "discrepancy_type", nullable = false, length = 64)
    private DiscrepancyType discrepancyType = DiscrepancyType.NONE;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private ReconciliationStatus status = ReconciliationStatus.MATCHED;

    @Column(name = "detected_at", nullable = false)
    private LocalDateTime detectedAt = LocalDateTime.now();

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }
    public String getProviderTransactionId() { return providerTransactionId; }
    public void setProviderTransactionId(String providerTransactionId) { this.providerTransactionId = providerTransactionId; }
    public String getInternalStatus() { return internalStatus; }
    public void setInternalStatus(String internalStatus) { this.internalStatus = internalStatus; }
    public String getProviderStatus() { return providerStatus; }
    public void setProviderStatus(String providerStatus) { this.providerStatus = providerStatus; }
    public BigDecimal getAmountInternal() { return amountInternal; }
    public void setAmountInternal(BigDecimal amountInternal) { this.amountInternal = amountInternal; }
    public BigDecimal getAmountProvider() { return amountProvider; }
    public void setAmountProvider(BigDecimal amountProvider) { this.amountProvider = amountProvider; }
    public DiscrepancyType getDiscrepancyType() { return discrepancyType; }
    public void setDiscrepancyType(DiscrepancyType discrepancyType) { this.discrepancyType = discrepancyType; }
    public ReconciliationStatus getStatus() { return status; }
    public void setStatus(ReconciliationStatus status) { this.status = status; }
    public LocalDateTime getDetectedAt() { return detectedAt; }
    public void setDetectedAt(LocalDateTime detectedAt) { this.detectedAt = detectedAt; }
    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }
}
