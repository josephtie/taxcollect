package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.PaymentQRCode;
import com.nectuxingenieries.collect.tax.services.PaymentQRCodeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/qr")
public class PaymentQRCodeController {

    @Autowired
    private PaymentQRCodeService paymentQRCodeService;

    @GetMapping("/{token}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<PaymentQRCode> resolveQRCode(@PathVariable String token) {
        return ResponseEntity.ok(paymentQRCodeService.resolveQRCode(token));
    }

    @PostMapping("/generate")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR')")
    public ResponseEntity<PaymentQRCode> generateQRCode(@RequestBody Map<String, Object> body) {
        Long collectionOrderId = Long.valueOf(body.get("collectionOrderId").toString());
        return ResponseEntity.ok(paymentQRCodeService.generateQRCode(collectionOrderId));
    }
}
