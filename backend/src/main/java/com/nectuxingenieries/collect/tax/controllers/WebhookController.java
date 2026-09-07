package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.Transaction;
import com.nectuxingenieries.collect.tax.services.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/payments/webhooks")
public class WebhookController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/{provider}")
    public ResponseEntity<?> handleWebhook(@PathVariable String provider, @RequestBody Map<String, Object> body) {
        // TODO — Authentifier la notification (signature HMAC ou asymétrique selon provider)
        // TODO — Vérifier l'idempotence (Redis)

        String providerTransactionId = (String) body.get("providerTransactionId");
        String status = (String) body.get("status");
        BigDecimal amount = body.containsKey("amount") ? new BigDecimal(body.get("amount").toString()) : null;
        String failureReason = (String) body.get("failureReason");

        Transaction transaction = paymentService.confirmPayment(providerTransactionId, provider, status, amount, failureReason);

        if (transaction != null) {
            return ResponseEntity.ok(Map.of(
                    "status", "CONFIRMED",
                    "transactionId", transaction.getId(),
                    "receiptNumber", transaction.getNumeroRecu()
            ));
        }

        return ResponseEntity.ok(Map.of("status", "PROCESSED"));
    }
}
