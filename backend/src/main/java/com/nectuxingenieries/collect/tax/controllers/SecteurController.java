package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.services.SecteurService;
import com.nectuxingenieries.collect.tax.dto.SecteurDto;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/secteur")
@RequiredArgsConstructor
@Tag(name = "Secteurs", description = "API de gestion des secteurs opérationnels")
public class SecteurController {

    private final SecteurService secteurService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<SecteurDto>> findAll() {
        List<SecteurDto> secteurs = secteurService.findAll();
        return ResponseEntity.ok(secteurs);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SecteurDto> findById(@PathVariable Long id) {
        return secteurService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<SecteurDto> create(@RequestBody SecteurDto secteurDto) {
        SecteurDto created = secteurService.create(secteurDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<SecteurDto> update(@PathVariable Long id, @RequestBody SecteurDto secteurDto) {
        SecteurDto updated = secteurService.update(id, secteurDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        secteurService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        secteurService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<SecteurDto>> findAllIncludingDeleted() {
        List<SecteurDto> secteurs = secteurService.findAllIncludingDeleted();
        return ResponseEntity.ok(secteurs);
    }

    @GetMapping("/locate")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SecteurDto> locateByGps(
            @RequestParam double lat,
            @RequestParam double lng) {
        return secteurService.locateByGps(lat, lng)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
