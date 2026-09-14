package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.services.SecteurService;
import com.nectuxingenieries.collect.tax.services.QuartierService;
import com.nectuxingenieries.collect.tax.services.ZoneService;
import com.nectuxingenieries.collect.tax.dto.SecteurDto;
import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.security.SecurityScopeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("api/taxcollect/secteur")
@RequiredArgsConstructor
@Tag(name = "Secteurs", description = "API de gestion des secteurs opérationnels")
public class SecteurController {

    private final SecteurService secteurService;
    private final QuartierService quartierService;
    private final ZoneService zoneService;
    private final SecurityScopeService securityScopeService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<List<SecteurDto>> findAll() {
        List<SecteurDto> secteurs = secteurService.findAll();
        if (securityScopeService.isAdmin()) {
            return ResponseEntity.ok(secteurs);
        }
        if (securityScopeService.isSuperviseur()) {
            String userId = securityScopeService.getCurrentUserId();
            Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .map(ZoneDto::getId)
                    .collect(Collectors.toSet());
            Set<Long> supervisedQuartierIds = quartierService.findAll().stream()
                    .filter(q -> supervisedZoneIds.contains(q.getZoneId()))
                    .map(QuartierDto::getId)
                    .collect(Collectors.toSet());
            List<SecteurDto> filtered = secteurs.stream()
                    .filter(s -> supervisedQuartierIds.contains(s.getQuartierId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        if (securityScopeService.isResponsableQuartier()) {
            String userId = securityScopeService.getCurrentUserId();
            Set<Long> myQuartierIds = quartierService.findAll().stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .map(QuartierDto::getId)
                    .collect(Collectors.toSet());
            List<SecteurDto> filtered = secteurs.stream()
                    .filter(s -> myQuartierIds.contains(s.getQuartierId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        return ResponseEntity.ok(secteurs);
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Alias de GET / — uniformise le référentiel avec commune/taxe/agent/contribuable")
    public ResponseEntity<List<SecteurDto>> findAllAlias() {
        return findAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<SecteurDto> findById(@PathVariable Long id) {
        return secteurService.findById(id)
                .map(secteur -> {
                    if (securityScopeService.isAdmin()) {
                        return ResponseEntity.ok(secteur);
                    }
                    if (securityScopeService.isSuperviseur()) {
                        String userId = securityScopeService.getCurrentUserId();
                        Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                                .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                                .map(ZoneDto::getId)
                                .collect(Collectors.toSet());
                        Set<Long> supervisedQuartierIds = quartierService.findAll().stream()
                                .filter(q -> supervisedZoneIds.contains(q.getZoneId()))
                                .map(QuartierDto::getId)
                                .collect(Collectors.toSet());
                        if (supervisedQuartierIds.contains(secteur.getQuartierId())) {
                            return ResponseEntity.ok(secteur);
                        }
                        return new ResponseEntity<SecteurDto>(HttpStatus.NOT_FOUND);
                    }
                    if (securityScopeService.isResponsableQuartier()) {
                        String userId = securityScopeService.getCurrentUserId();
                        Set<Long> myQuartierIds = quartierService.findAll().stream()
                                .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                                .map(QuartierDto::getId)
                                .collect(Collectors.toSet());
                        if (myQuartierIds.contains(secteur.getQuartierId())) {
                            return ResponseEntity.ok(secteur);
                        }
                        return new ResponseEntity<SecteurDto>(HttpStatus.NOT_FOUND);
                    }
                    return ResponseEntity.ok(secteur);
                })
                .orElseGet(() -> new ResponseEntity<SecteurDto>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SecteurDto> create(@RequestBody SecteurDto secteurDto) {
        SecteurDto created = secteurService.create(secteurDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SecteurDto> update(@PathVariable Long id, @RequestBody SecteurDto secteurDto) {
        SecteurDto updated = secteurService.update(id, secteurDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        secteurService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        secteurService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<SecteurDto>> findAllIncludingDeleted() {
        List<SecteurDto> secteurs = secteurService.findAllIncludingDeleted();
        return ResponseEntity.ok(secteurs);
    }

    @GetMapping("/locate")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER', 'AGENT')")
    public ResponseEntity<SecteurDto> locateByGps(
            @RequestParam double lat,
            @RequestParam double lng) {
        return secteurService.locateByGps(lat, lng)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/quartier/{quartierId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Lister les secteurs d'un quartier (filtrés selon le périmètre de l'appelant)")
    public ResponseEntity<List<SecteurDto>> findByQuartier(@PathVariable Long quartierId) {
        return ResponseEntity.ok(applyScope(secteurService.findByQuartierId(quartierId)));
    }

    /**
     * Restreint une liste de secteurs au périmètre territorial de l'utilisateur courant.
     * ADMIN voit tout, SUPERVISEUR les secteurs des quartiers de ses zones,
     * RESPONSABLE_QUARTIER les secteurs de ses propres quartiers.
     */
    private List<SecteurDto> applyScope(List<SecteurDto> secteurs) {
        if (securityScopeService.isAdmin()) {
            return secteurs;
        }
        String userId = securityScopeService.getCurrentUserId();
        if (securityScopeService.isSuperviseur()) {
            Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .map(ZoneDto::getId)
                    .collect(Collectors.toSet());
            Set<Long> supervisedQuartierIds = quartierService.findAll().stream()
                    .filter(q -> supervisedZoneIds.contains(q.getZoneId()))
                    .map(QuartierDto::getId)
                    .collect(Collectors.toSet());
            return secteurs.stream()
                    .filter(s -> supervisedQuartierIds.contains(s.getQuartierId()))
                    .collect(Collectors.toList());
        }
        if (securityScopeService.isResponsableQuartier()) {
            Set<Long> myQuartierIds = quartierService.findAll().stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .map(QuartierDto::getId)
                    .collect(Collectors.toSet());
            return secteurs.stream()
                    .filter(s -> myQuartierIds.contains(s.getQuartierId()))
                    .collect(Collectors.toList());
        }
        return secteurs;
    }
}
