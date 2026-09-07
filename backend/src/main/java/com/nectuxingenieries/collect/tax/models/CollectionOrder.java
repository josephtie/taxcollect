package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.CollectionOrderStatus;
import com.nectuxingenieries.collect.tax.models.enums.PaymentChannel;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "collection_order")
public class CollectionOrder extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 128)
    private String reference;

    @Column(name = "taxe_collect_id", nullable = false)
    private Long taxeCollectId;

    @Column(name = "contribuable_id", nullable = false)
    private Long contribuableId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 8)
    private String currency = "XOF";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private PaymentChannel channel;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private CollectionOrderStatus status = CollectionOrderStatus.OPEN;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public Long getTaxeCollectId() { return taxeCollectId; }
    public void setTaxeCollectId(Long taxeCollectId) { this.taxeCollectId = taxeCollectId; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public PaymentChannel getChannel() { return channel; }
    public void setChannel(PaymentChannel channel) { this.channel = channel; }
    public CollectionOrderStatus getStatus() { return status; }
    public void setStatus(CollectionOrderStatus status) { this.status = status; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
}
