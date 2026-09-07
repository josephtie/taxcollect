package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.CollectionOrder;
import com.nectuxingenieries.collect.tax.models.enums.PaymentChannel;
import com.nectuxingenieries.collect.tax.payment.dto.PaymentInitiationResponse;
import com.nectuxingenieries.collect.tax.payment.dto.PaymentStatusResponse;
import com.nectuxingenieries.collect.tax.services.PaymentService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@Tag(name = "Paiements", description = "API de gestion des paiements")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<PaymentInitiationResponse> initiatePayment(@RequestBody Map<String, Object> body) {
        Long collectionOrderId = Long.valueOf(body.get("collectionOrderId").toString());
        String paymentMethod = body.getOrDefault("paymentMethod", "MOBILE_MONEY").toString();
        String idempotencyKey = (String) body.getOrDefault("idempotencyKey",
                "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        PaymentInitiationResponse response = paymentService.initiatePayment(collectionOrderId, paymentMethod, idempotencyKey);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{reference}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<PaymentStatusResponse> getPaymentStatus(@PathVariable String reference) {
        return ResponseEntity.ok(paymentService.getPaymentStatus(reference));
    }

    @PostMapping("/{reference}/cancel")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR')")
    public ResponseEntity<Void> cancelPayment(@PathVariable String reference) {
        // TODO — Implémenter l'annulation via le provider
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{reference}/refund")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    public ResponseEntity<Void> refundPayment(@PathVariable String reference, @RequestBody Map<String, Object> body) {
        // TODO — Implémenter le remboursement via le provider
        return ResponseEntity.ok().build();
    }
}
