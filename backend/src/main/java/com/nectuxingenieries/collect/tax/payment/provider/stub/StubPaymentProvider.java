package com.nectuxingenieries.collect.tax.payment.provider.stub;

import com.nectuxingenieries.collect.tax.payment.PaymentProvider;
import com.nectuxingenieries.collect.tax.payment.dto.*;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class StubPaymentProvider implements PaymentProvider {

    @Override
    public PaymentInitiationResponse initiatePayment(PaymentInitiationRequest request) {
        PaymentInitiationResponse response = new PaymentInitiationResponse();
        response.setProviderTransactionId("STUB-" + UUID.randomUUID());
        response.setStatus("PENDING");
        response.setRedirectUrl(null);
        return response;
    }

    @Override
    public PaymentStatusResponse getPaymentStatus(String providerTransactionId) {
        PaymentStatusResponse response = new PaymentStatusResponse();
        response.setProviderTransactionId(providerTransactionId);
        response.setStatus("SUCCESS");
        return response;
    }

    @Override
    public PaymentRefundResponse refund(RefundRequest request) {
        PaymentRefundResponse response = new PaymentRefundResponse();
        response.setProviderRefundId("STUB-REFUND-" + UUID.randomUUID());
        response.setStatus("SUCCESS");
        return response;
    }

    @Override
    public PaymentRequestResponse createPaymentRequest(PaymentRequestDTO request) {
        PaymentRequestResponse response = new PaymentRequestResponse();
        response.setProviderRequestId("STUB-RTP-" + UUID.randomUUID());
        response.setStatus("RTP_SENT");
        return response;
    }

    @Override
    public PaymentRequestStatusResponse getPaymentRequestStatus(String providerRequestId) {
        PaymentRequestStatusResponse response = new PaymentRequestStatusResponse();
        response.setProviderRequestId(providerRequestId);
        response.setStatus("RTP_PENDING");
        return response;
    }

    @Override
    public String getProviderCode() {
        return "STUB";
    }
}
