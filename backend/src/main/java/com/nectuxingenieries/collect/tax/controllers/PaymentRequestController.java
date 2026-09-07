package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.PaymentRequest;
import com.nectuxingenieries.collect.tax.repositories.PaymentRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

// TODO — Implémenter la logique RTP complète via PaymentProvider.createPaymentRequest
@RestController
@RequestMapping("/api/payment-requests")
public class PaymentRequestController {

    @Autowired
    private PaymentRequestRepository paymentRequestRepository;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR')")
    public ResponseEntity<PaymentRequest> createPaymentRequest(@RequestBody PaymentRequest request) {
        // TODO — Déléguer au PaymentProvider via PaymentService
        return ResponseEntity.ok(paymentRequestRepository.save(request));
    }

    @GetMapping("/{reference}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<PaymentRequest> getPaymentRequest(@PathVariable String reference) {
        return ResponseEntity.ok(paymentRequestRepository.findByReference(reference)
                .orElseThrow(() -> new NotFoundException("PaymentRequest", reference)));
    }

    @PostMapping("/{reference}/cancel")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR')")
    public ResponseEntity<Void> cancelPaymentRequest(@PathVariable String reference) {
        // TODO — Implémenter l'annulation RTP via le provider
        return ResponseEntity.noContent().build();
    }
}
