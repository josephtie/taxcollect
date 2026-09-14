package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.PromessePaiementDto;
import com.nectuxingenieries.collect.tax.services.PromessePaiementService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("api/taxcollect/promesse")
@RequiredArgsConstructor
@Tag(name = "Promesses de paiement", description = "API de gestion des promesses de paiement")
public class PromessePaiementController {

    private final PromessePaiementService promesseService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<PromessePaiementDto>> findAll() {
        return ResponseEntity.ok(promesseService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<PromessePaiementDto> findById(@PathVariable Long id) {
        return promesseService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/contribuable/{contribuableId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<PromessePaiementDto>> findByContribuable(@PathVariable Long contribuableId) {
        return ResponseEntity.ok(promesseService.findByContribuableId(contribuableId));
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<PromessePaiementDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(promesseService.findByAgentId(agentId));
    }

    @GetMapping("/echeances")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<PromessePaiementDto>> findEcheancesProches(@RequestParam LocalDate date) {
        return ResponseEntity.ok(promesseService.findEcheancesProches(date));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<PromessePaiementDto> create(@RequestBody PromessePaiementDto promesseDto) {
        PromessePaiementDto created = promesseService.create(promesseDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<PromessePaiementDto> update(@PathVariable Long id, @RequestBody PromessePaiementDto promesseDto) {
        return ResponseEntity.ok(promesseService.update(id, promesseDto));
    }

    @PostMapping("/{id}/relance")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<PromessePaiementDto> marquerRelance(@PathVariable Long id) {
        return ResponseEntity.ok(promesseService.marquerRelance(id));
    }

    @PostMapping("/{id}/honoree")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<PromessePaiementDto> marquerHonoree(@PathVariable Long id) {
        return ResponseEntity.ok(promesseService.marquerHonoree(id));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        promesseService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        promesseService.restore(id);
        return ResponseEntity.ok().build();
    }
}
