package com.nectuxingenieries.collect.tax.payment.dto;

public class PaymentInitiationResponse {
    private String providerTransactionId;
    private String status;
    private String redirectUrl;
    private String failureReason;

    public String getProviderTransactionId() { return providerTransactionId; }
    public void setProviderTransactionId(String providerTransactionId) { this.providerTransactionId = providerTransactionId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRedirectUrl() { return redirectUrl; }
    public void setRedirectUrl(String redirectUrl) { this.redirectUrl = redirectUrl; }
    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }
}
