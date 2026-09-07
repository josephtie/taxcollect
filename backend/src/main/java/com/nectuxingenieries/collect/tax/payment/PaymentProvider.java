package com.nectuxingenieries.collect.tax.payment;

import com.nectuxingenieries.collect.tax.payment.dto.*;

public interface PaymentProvider {

    PaymentInitiationResponse initiatePayment(PaymentInitiationRequest request);

    PaymentStatusResponse getPaymentStatus(String providerTransactionId);

    PaymentRefundResponse refund(RefundRequest request);

    PaymentRequestResponse createPaymentRequest(PaymentRequestDTO request);

    PaymentRequestStatusResponse getPaymentRequestStatus(String providerRequestId);

    String getProviderCode();
}
