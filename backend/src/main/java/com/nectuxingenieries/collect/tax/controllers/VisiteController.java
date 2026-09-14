package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.VisiteDto;
import com.nectuxingenieries.collect.tax.services.VisiteService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/visite")
@RequiredArgsConstructor
@Tag(name = "Visites", description = "API de gestion des visites de terrain")
public class VisiteController {

    private final VisiteService visiteService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<VisiteDto>> findAll() {
        return ResponseEntity.ok(visiteService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<VisiteDto> findById(@PathVariable Long id) {
        return visiteService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/tournee/{tourneeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<VisiteDto>> findByTournee(@PathVariable Long tourneeId) {
        return ResponseEntity.ok(visiteService.findByTourneeId(tourneeId));
    }

    @GetMapping("/contribuable/{contribuableId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<VisiteDto>> findByContribuable(@PathVariable Long contribuableId) {
        return ResponseEntity.ok(visiteService.findByContribuableId(contribuableId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<VisiteDto> create(@RequestBody VisiteDto visiteDto) {
        VisiteDto created = visiteService.create(visiteDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<VisiteDto> update(@PathVariable Long id, @RequestBody VisiteDto visiteDto) {
        return ResponseEntity.ok(visiteService.update(id, visiteDto));
    }

    @PatchMapping("/{id}/statut")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<VisiteDto> updateStatut(
            @PathVariable Long id,
            @RequestParam String statut,
            @RequestParam(required = false) String motif,
            @RequestParam(required = false) String observation) {
        return ResponseEntity.ok(visiteService.updateStatut(id, statut, motif, observation));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        visiteService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        visiteService.restore(id);
        return ResponseEntity.ok().build();
    }
}
