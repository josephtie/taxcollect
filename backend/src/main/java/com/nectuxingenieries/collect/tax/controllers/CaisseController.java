package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.CaisseDto;
import com.nectuxingenieries.collect.tax.services.CaisseService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("api/taxcollect/caisse")
@RequiredArgsConstructor
@Tag(name = "Caisse", description = "API de gestion de caisse agent")
public class CaisseController {

    private final CaisseService caisseService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<List<CaisseDto>> findAll() {
        return ResponseEntity.ok(caisseService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<CaisseDto> findById(@PathVariable Long id) {
        return caisseService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<List<CaisseDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(caisseService.findByAgentId(agentId));
    }

    @GetMapping("/agent/{agentId}/date/{date}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<CaisseDto> findByAgentAndDate(@PathVariable Long agentId, @PathVariable LocalDate date) {
        return caisseService.findByAgentAndDate(agentId, date)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<CaisseDto> create(@RequestBody CaisseDto caisseDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(caisseService.create(caisseDto));
    }

    @PostMapping("/{id}/ouvrir")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<CaisseDto> ouvrir(@PathVariable Long id) {
        return ResponseEntity.ok(caisseService.ouvrirCaisse(id));
    }

    @PostMapping("/{id}/cloturer")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT', 'TRESOR')")
    public ResponseEntity<CaisseDto> cloturer(@PathVariable Long id) {
        return ResponseEntity.ok(caisseService.cloturerCaisse(id));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        caisseService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
