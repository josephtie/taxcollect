package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "receipt")
public class Receipt extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "receipt_number", nullable = false, unique = true, length = 128)
    private String receiptNumber;

    @Column(name = "transaction_id", nullable = false)
    private Long transactionId;

    @Column(name = "taxe_collect_id")
    private Long taxeCollectId;

    @Column(name = "taxpayer_id")
    private Long taxpayerId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 8)
    private String currency = "XOF";

    @Column(length = 32)
    private String provider;

    @Column(name = "provider_transaction_id", length = 128)
    private String providerTransactionId;

    @Column(name = "issued_at", nullable = false)
    private LocalDateTime issuedAt = LocalDateTime.now();

    @Column(name = "pdf_url", length = 512)
    private String pdfUrl;

    @Column(name = "pdf_content", columnDefinition = "TEXT")
    private String pdfContent;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getReceiptNumber() { return receiptNumber; }
    public void setReceiptNumber(String receiptNumber) { this.receiptNumber = receiptNumber; }
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }
    public Long getTaxeCollectId() { return taxeCollectId; }
    public void setTaxeCollectId(Long taxeCollectId) { this.taxeCollectId = taxeCollectId; }
    public Long getTaxpayerId() { return taxpayerId; }
    public void setTaxpayerId(Long taxpayerId) { this.taxpayerId = taxpayerId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getProviderTransactionId() { return providerTransactionId; }
    public void setProviderTransactionId(String providerTransactionId) { this.providerTransactionId = providerTransactionId; }
    public LocalDateTime getIssuedAt() { return issuedAt; }
    public void setIssuedAt(LocalDateTime issuedAt) { this.issuedAt = issuedAt; }
    public String getPdfUrl() { return pdfUrl; }
    public void setPdfUrl(String pdfUrl) { this.pdfUrl = pdfUrl; }
    public String getPdfContent() { return pdfContent; }
    public void setPdfContent(String pdfContent) { this.pdfContent = pdfContent; }
}
