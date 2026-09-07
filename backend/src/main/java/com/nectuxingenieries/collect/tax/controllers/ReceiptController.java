package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Receipt;
import com.nectuxingenieries.collect.tax.repositories.ReceiptRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/receipts")
public class ReceiptController {

    @Autowired
    private ReceiptRepository receiptRepository;

    @GetMapping("/{receiptNumber}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<Receipt> getReceipt(@PathVariable String receiptNumber) {
        return ResponseEntity.ok(receiptRepository.findByReceiptNumber(receiptNumber)
                .orElseThrow(() -> new NotFoundException("Receipt", receiptNumber)));
    }

    @GetMapping("/{receiptNumber}/pdf")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<byte[]> getReceiptPdf(@PathVariable String receiptNumber) {
        // TODO — Générer le PDF du reçu (Apache POI ou iText)
        Receipt receipt = receiptRepository.findByReceiptNumber(receiptNumber)
                .orElseThrow(() -> new NotFoundException("Receipt", receiptNumber));
        return ResponseEntity.noContent().build();
    }
}
