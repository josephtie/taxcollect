package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import com.nectuxingenieries.collect.tax.dto.SecteurDto;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.services.QuartierService;
import com.nectuxingenieries.collect.tax.services.SecteurService;
import com.nectuxingenieries.collect.tax.services.ZoneService;
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
@RequestMapping("api/taxcollect/quartier")
@RequiredArgsConstructor
@Tag(name = "Quartiers", description = "API de gestion des quartiers")
public class QuartierController {

    private final QuartierService quartierService;
    private final ZoneService zoneService;
    private final SecteurService secteurService;
    private final SecurityScopeService securityScopeService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<List<QuartierDto>> findAll() {
        List<QuartierDto> quartiers = quartierService.findAll();
        if (securityScopeService.isAdmin()) {
            return ResponseEntity.ok(quartiers);
        }
        if (securityScopeService.isSuperviseur()) {
            String userId = securityScopeService.getCurrentUserId();
            Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .map(ZoneDto::getId)
                    .collect(Collectors.toSet());
            List<QuartierDto> filtered = quartiers.stream()
                    .filter(q -> supervisedZoneIds.contains(q.getZoneId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        if (securityScopeService.isResponsableQuartier()) {
            String userId = securityScopeService.getCurrentUserId();
            List<QuartierDto> filtered = quartiers.stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        return ResponseEntity.ok(quartiers);
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Alias de GET / — uniformise le référentiel avec commune/taxe/agent/contribuable")
    public ResponseEntity<List<QuartierDto>> findAllAlias() {
        return findAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<QuartierDto> findById(@PathVariable Long id) {
        return quartierService.findById(id)
                .map(quartier -> {
                    if (securityScopeService.isAdmin()) {
                        return ResponseEntity.ok(quartier);
                    }
                    if (securityScopeService.isSuperviseur()) {
                        String userId = securityScopeService.getCurrentUserId();
                        Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                                .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                                .map(ZoneDto::getId)
                                .collect(Collectors.toSet());
                        if (supervisedZoneIds.contains(quartier.getZoneId())) {
                            return ResponseEntity.ok(quartier);
                        }
                        return new ResponseEntity<QuartierDto>(HttpStatus.NOT_FOUND);
                    }
                    if (securityScopeService.isResponsableQuartier()) {
                        String userId = securityScopeService.getCurrentUserId();
                        if (userId != null && userId.equals(quartier.getResponsableId())) {
                            return ResponseEntity.ok(quartier);
                        }
                        return new ResponseEntity<QuartierDto>(HttpStatus.NOT_FOUND);
                    }
                    return ResponseEntity.ok(quartier);
                })
                .orElseGet(() -> new ResponseEntity<QuartierDto>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<QuartierDto> create(@RequestBody QuartierDto quartierDto) {
        QuartierDto created = quartierService.create(quartierDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<QuartierDto> update(@PathVariable Long id, @RequestBody QuartierDto quartierDto) {
        QuartierDto updated = quartierService.update(id, quartierDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        quartierService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        quartierService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<QuartierDto>> findAllIncludingDeleted() {
        List<QuartierDto> quartiers = quartierService.findAllIncludingDeleted();
        return ResponseEntity.ok(quartiers);
    }

    @GetMapping("/zone/{zoneId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Lister les quartiers d'une zone (filtrés selon le périmètre de l'appelant)")
    public ResponseEntity<List<QuartierDto>> findByZone(@PathVariable Long zoneId) {
        return ResponseEntity.ok(applyScope(quartierService.findByZoneId(zoneId)));
    }

    @GetMapping("/{quartierId}/secteurs")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Lister les secteurs d'un quartier")
    public ResponseEntity<List<SecteurDto>> findSecteurs(@PathVariable Long quartierId) {
        boolean visible = applyScope(quartierService.findByZoneId(
                        quartierService.findById(quartierId).map(QuartierDto::getZoneId).orElse(-1L)))
                .stream()
                .anyMatch(q -> quartierId.equals(q.getId()));
        if (!visible) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return ResponseEntity.ok(secteurService.findByQuartierId(quartierId));
    }

    /**
     * Restreint une liste de quartiers au périmètre territorial de l'utilisateur courant.
     * ADMIN voit tout, SUPERVISEUR les quartiers de ses zones, RESPONSABLE_QUARTIER ses
     * propres quartiers.
     */
    private List<QuartierDto> applyScope(List<QuartierDto> quartiers) {
        if (securityScopeService.isAdmin()) {
            return quartiers;
        }
        String userId = securityScopeService.getCurrentUserId();
        if (securityScopeService.isSuperviseur()) {
            Set<Long> supervisedZoneIds = zoneService.findAll().stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .map(ZoneDto::getId)
                    .collect(Collectors.toSet());
            return quartiers.stream()
                    .filter(q -> supervisedZoneIds.contains(q.getZoneId()))
                    .collect(Collectors.toList());
        }
        if (securityScopeService.isResponsableQuartier()) {
            return quartiers.stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .collect(Collectors.toList());
        }
        return quartiers;
    }
}
