package com.nectuxingenieries.collect.tax.payment.provider.psp;

import com.nectuxingenieries.collect.tax.payment.PaymentProvider;
import com.nectuxingenieries.collect.tax.payment.dto.*;
import org.springframework.stereotype.Component;

// TODO — Implémentation PSPProvider (CinetPay, Fedapay, etc.)
// À implémenter lorsque l'intégration avec un PSP spécifique sera confirmée.
@Component
public class PSPProvider implements PaymentProvider {

    @Override
    public PaymentInitiationResponse initiatePayment(PaymentInitiationRequest request) {
        // TODO — Implémenter l'appel API du PSP (CinetPay, Fedapay, etc.)
        throw new UnsupportedOperationException("PSPProvider not yet implemented — pending PSP integration specification");
    }

    @Override
    public PaymentStatusResponse getPaymentStatus(String providerTransactionId) {
        // TODO — Implémenter la vérification de statut auprès du PSP
        throw new UnsupportedOperationException("PSPProvider not yet implemented — pending PSP integration specification");
    }

    @Override
    public PaymentRefundResponse refund(RefundRequest request) {
        // TODO — Implémenter le remboursement via le PSP
        throw new UnsupportedOperationException("PSPProvider not yet implemented — pending PSP integration specification");
    }

    @Override
    public PaymentRequestResponse createPaymentRequest(PaymentRequestDTO request) {
        // TODO — Implémenter le RTP via le PSP
        throw new UnsupportedOperationException("PSPProvider not yet implemented — pending PSP integration specification");
    }

    @Override
    public PaymentRequestStatusResponse getPaymentRequestStatus(String providerRequestId) {
        // TODO — Implémenter la vérification de statut RTP auprès du PSP
        throw new UnsupportedOperationException("PSPProvider not yet implemented — pending PSP integration specification");
    }

    @Override
    public String getProviderCode() {
        return "PSP";
    }
}
