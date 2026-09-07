package com.nectuxingenieries.collect.tax.payment.provider.pisp;

import com.nectuxingenieries.collect.tax.payment.PaymentProvider;
import com.nectuxingenieries.collect.tax.payment.dto.*;
import org.springframework.stereotype.Component;

// TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
// Avant d'implémenter PISPIProvider, analyser la documentation officielle PI-SPI
// et identifier précisément : endpoints, méthodes HTTP, authentification, certificats,
// formats JSON/XML, headers, identifiants, statuts, codes d'erreur, webhooks/callbacks,
// exigences de signature, mécanisme d'idempotence, sandbox, production.
@Component
public class PISPIProvider implements PaymentProvider {

    @Override
    public PaymentInitiationResponse initiatePayment(PaymentInitiationRequest request) {
        // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
        throw new UnsupportedOperationException("PISPIProvider not yet implemented — pending official PI-SPI documentation");
    }

    @Override
    public PaymentStatusResponse getPaymentStatus(String providerTransactionId) {
        // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
        throw new UnsupportedOperationException("PISPIProvider not yet implemented — pending official PI-SPI documentation");
    }

    @Override
    public PaymentRefundResponse refund(RefundRequest request) {
        // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
        throw new UnsupportedOperationException("PISPIProvider not yet implemented — pending official PI-SPI documentation");
    }

    @Override
    public PaymentRequestResponse createPaymentRequest(PaymentRequestDTO request) {
        // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
        throw new UnsupportedOperationException("PISPIProvider not yet implemented — pending official PI-SPI documentation");
    }

    @Override
    public PaymentRequestStatusResponse getPaymentRequestStatus(String providerRequestId) {
        // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
        throw new UnsupportedOperationException("PISPIProvider not yet implemented — pending official PI-SPI documentation");
    }

    @Override
    public String getProviderCode() {
        return "PISPI";
    }
}
