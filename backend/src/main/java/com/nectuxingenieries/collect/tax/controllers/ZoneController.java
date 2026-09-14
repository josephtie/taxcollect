package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.services.ZoneService;
import com.nectuxingenieries.collect.tax.services.QuartierService;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.dto.QuartierDto;
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
@RequestMapping("api/taxcollect/zone")
@RequiredArgsConstructor
@Tag(name = "Zones", description = "API de gestion des zones")
public class ZoneController {

    private final ZoneService zoneService;
    private final QuartierService quartierService;
    private final SecurityScopeService securityScopeService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<List<ZoneDto>> findAll() {
        List<ZoneDto> zones = zoneService.findAll();
        if (securityScopeService.isAdmin()) {
            return ResponseEntity.ok(zones);
        }
        if (securityScopeService.isSuperviseur()) {
            String userId = securityScopeService.getCurrentUserId();
            List<ZoneDto> filtered = zones.stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        if (securityScopeService.isResponsableQuartier()) {
            String userId = securityScopeService.getCurrentUserId();
            Set<Long> myZoneIds = quartierService.findAll().stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .map(QuartierDto::getZoneId)
                    .collect(Collectors.toSet());
            List<ZoneDto> filtered = zones.stream()
                    .filter(z -> myZoneIds.contains(z.getId()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtered);
        }
        return ResponseEntity.ok(zones);
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Alias de GET / — uniformise le référentiel avec commune/taxe/agent/contribuable")
    public ResponseEntity<List<ZoneDto>> findAllAlias() {
        return findAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<ZoneDto> findById(@PathVariable Long id) {
        return zoneService.findById(id)
                .map(zone -> {
                    if (securityScopeService.isAdmin()) {
                        return ResponseEntity.ok(zone);
                    }
                    if (securityScopeService.isSuperviseur()) {
                        String userId = securityScopeService.getCurrentUserId();
                        if (userId != null && userId.equals(zone.getSuperviseurId())) {
                            return ResponseEntity.ok(zone);
                        }
                        return new ResponseEntity<ZoneDto>(HttpStatus.NOT_FOUND);
                    }
                    if (securityScopeService.isResponsableQuartier()) {
                        String userId = securityScopeService.getCurrentUserId();
                        Set<Long> myZoneIds = quartierService.findAll().stream()
                                .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                                .map(QuartierDto::getZoneId)
                                .collect(Collectors.toSet());
                        if (myZoneIds.contains(zone.getId())) {
                            return ResponseEntity.ok(zone);
                        }
                        return new ResponseEntity<ZoneDto>(HttpStatus.NOT_FOUND);
                    }
                    return ResponseEntity.ok(zone);
                })
                .orElseGet(() -> new ResponseEntity<ZoneDto>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ZoneDto> create(@RequestBody ZoneDto zoneDto) {
        ZoneDto created = zoneService.create(zoneDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ZoneDto> update(@PathVariable Long id, @RequestBody ZoneDto zoneDto) {
        ZoneDto updated = zoneService.update(id, zoneDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        zoneService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        zoneService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ZoneDto>> findAllIncludingDeleted() {
        List<ZoneDto> zones = zoneService.findAllIncludingDeleted();
        return ResponseEntity.ok(zones);
    }

    @GetMapping("/commune/{communeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Lister les zones d'une commune (filtrées selon le périmètre de l'appelant)")
    public ResponseEntity<List<ZoneDto>> findByCommune(@PathVariable Long communeId) {
        return ResponseEntity.ok(applyScope(zoneService.findByCommuneId(communeId)));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Rechercher des zones par nom ou commune (filtrées selon le périmètre de l'appelant)")
    public ResponseEntity<List<ZoneDto>> search(@RequestParam(required = false) String search) {
        return ResponseEntity.ok(applyScope(zoneService.search(search)));
    }

    /**
     * Restreint une liste de zones au périmètre territorial de l'utilisateur courant.
     * ADMIN voit tout, SUPERVISEUR ses zones supervisées, RESPONSABLE_QUARTIER les zones
     * qui contiennent au moins un de ses quartiers.
     */
    private List<ZoneDto> applyScope(List<ZoneDto> zones) {
        if (securityScopeService.isAdmin()) {
            return zones;
        }
        String userId = securityScopeService.getCurrentUserId();
        if (securityScopeService.isSuperviseur()) {
            return zones.stream()
                    .filter(z -> userId != null && userId.equals(z.getSuperviseurId()))
                    .collect(Collectors.toList());
        }
        if (securityScopeService.isResponsableQuartier()) {
            Set<Long> myZoneIds = quartierService.findAll().stream()
                    .filter(q -> userId != null && userId.equals(q.getResponsableId()))
                    .map(QuartierDto::getZoneId)
                    .collect(Collectors.toSet());
            return zones.stream()
                    .filter(z -> myZoneIds.contains(z.getId()))
                    .collect(Collectors.toList());
        }
        return zones;
    }
}
