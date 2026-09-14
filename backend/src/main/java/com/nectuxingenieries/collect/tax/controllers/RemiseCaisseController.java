package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.RemiseCaisseDto;
import com.nectuxingenieries.collect.tax.services.RemiseCaisseService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/remise-caisse")
@RequiredArgsConstructor
@Tag(name = "Remise de caisse", description = "API de gestion des remises de caisse")
public class RemiseCaisseController {

    private final RemiseCaisseService remiseService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<List<RemiseCaisseDto>> findAll() {
        return ResponseEntity.ok(remiseService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<RemiseCaisseDto> findById(@PathVariable Long id) {
        return remiseService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/caisse/{caisseId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<List<RemiseCaisseDto>> findByCaisse(@PathVariable Long caisseId) {
        return ResponseEntity.ok(remiseService.findByCaisseId(caisseId));
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    public ResponseEntity<List<RemiseCaisseDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(remiseService.findByAgentId(agentId));
    }

    @GetMapping("/statut/{statut}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<List<RemiseCaisseDto>> findByStatut(@PathVariable String statut) {
        return ResponseEntity.ok(remiseService.findByStatut(statut));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<RemiseCaisseDto> create(@RequestBody RemiseCaisseDto remiseDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(remiseService.create(remiseDto));
    }

    @PostMapping("/{id}/confirmer")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<RemiseCaisseDto> confirmer(
            @PathVariable Long id,
            @RequestParam Long confirmePar,
            @RequestParam(required = false) String commentaire) {
        return ResponseEntity.ok(remiseService.confirmer(id, confirmePar, commentaire));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        remiseService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
