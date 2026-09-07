package com.nectuxingenieries.collect.tax.payment.dto;

import java.math.BigDecimal;

public class PaymentInitiationRequest {
    private String collectionOrderReference;
    private String taxReference;
    private Long taxpayerId;
    private BigDecimal amount;
    private String currency;
    private String paymentMethod;
    private String idempotencyKey;
    private String communeCode;
    private String channel;

    public String getCollectionOrderReference() { return collectionOrderReference; }
    public void setCollectionOrderReference(String collectionOrderReference) { this.collectionOrderReference = collectionOrderReference; }
    public String getTaxReference() { return taxReference; }
    public void setTaxReference(String taxReference) { this.taxReference = taxReference; }
    public Long getTaxpayerId() { return taxpayerId; }
    public void setTaxpayerId(Long taxpayerId) { this.taxpayerId = taxpayerId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getIdempotencyKey() { return idempotencyKey; }
    public void setIdempotencyKey(String idempotencyKey) { this.idempotencyKey = idempotencyKey; }
    public String getCommuneCode() { return communeCode; }
    public void setCommuneCode(String communeCode) { this.communeCode = communeCode; }
    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }
}
