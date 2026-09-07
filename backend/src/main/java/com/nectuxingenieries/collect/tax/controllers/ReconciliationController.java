package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Reconciliation;
import com.nectuxingenieries.collect.tax.repositories.ReconciliationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reconciliation")
public class ReconciliationController {

    @Autowired
    private ReconciliationRepository reconciliationRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    public ResponseEntity<List<Reconciliation>> getAll() {
        return ResponseEntity.ok(reconciliationRepository.findAll());
    }

    @GetMapping("/{reference}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    public ResponseEntity<Reconciliation> getByReference(@PathVariable String reference) {
        return ResponseEntity.ok(reconciliationRepository.findByReference(reference)
                .orElseThrow(() -> new NotFoundException("Reconciliation", reference)));
    }
}
