package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.RTPStatus;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment_request")
public class PaymentRequest extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 128)
    private String reference;

    @Column(name = "collection_order_id", nullable = false)
    private Long collectionOrderId;

    @Column(name = "taxpayer_id", nullable = false)
    private Long taxpayerId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 8)
    private String currency = "XOF";

    @Column(nullable = false, length = 32)
    private String provider;

    @Column(name = "provider_request_id", length = 128)
    private String providerRequestId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private RTPStatus status = RTPStatus.RTP_CREATED;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "accepted_at")
    private LocalDateTime acceptedAt;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public Long getCollectionOrderId() { return collectionOrderId; }
    public void setCollectionOrderId(Long collectionOrderId) { this.collectionOrderId = collectionOrderId; }
    public Long getTaxpayerId() { return taxpayerId; }
    public void setTaxpayerId(Long taxpayerId) { this.taxpayerId = taxpayerId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getProviderRequestId() { return providerRequestId; }
    public void setProviderRequestId(String providerRequestId) { this.providerRequestId = providerRequestId; }
    public RTPStatus getStatus() { return status; }
    public void setStatus(RTPStatus status) { this.status = status; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }
    public LocalDateTime getAcceptedAt() { return acceptedAt; }
    public void setAcceptedAt(LocalDateTime acceptedAt) { this.acceptedAt = acceptedAt; }
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
}
