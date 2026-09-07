package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.CollectionOrder;
import com.nectuxingenieries.collect.tax.models.enums.PaymentChannel;
import com.nectuxingenieries.collect.tax.repositories.CollectionOrderRepository;
import com.nectuxingenieries.collect.tax.services.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/collection-orders")
public class CollectionOrderController {

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private CollectionOrderRepository collectionOrderRepository;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<CollectionOrder> createCollectionOrder(@RequestBody Map<String, Object> body) {
        Long taxeCollectId = Long.valueOf(body.get("taxeCollectId").toString());
        String channelStr = body.getOrDefault("channel", "DIRECT_PAYMENT").toString();
        PaymentChannel channel = PaymentChannel.valueOf(channelStr);
        return ResponseEntity.ok(paymentService.createCollectionOrder(taxeCollectId, channel));
    }

    @GetMapping("/{reference}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'AGENT', 'SUPERVISEUR', 'CONTRIBUABLE')")
    public ResponseEntity<CollectionOrder> getCollectionOrder(@PathVariable String reference) {
        return ResponseEntity.ok(collectionOrderRepository.findByReference(reference)
                .orElseThrow(() -> new NotFoundException("CollectionOrder", reference)));
    }
}
