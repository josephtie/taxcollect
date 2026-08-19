package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.services.ZoneCollecteService;
import com.nectuxingenieries.collect.tax.dto.ZoneCollectDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.nectuxingenieries.collect.tax.dto.*;
import java.util.List;

@RestController
@RequestMapping("api/taxcollect/zone")
@RequiredArgsConstructor
@Tag(name = "Zones", description = "API de gestion des zones de collecte")
public class ZoneController {

    private final ZoneCollecteService zoneService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<ZoneCollectDto>> findAll() {
        List<ZoneCollectDto> zones = zoneService.findAll();
        return ResponseEntity.ok(zones);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<ZoneCollectDto> findById(@PathVariable Long id) {
        return zoneService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<ZoneCollectDto> create(@RequestBody ZoneCollectDto zoneDto) {
        ZoneCollectDto created = zoneService.create(zoneDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<ZoneCollectDto> update(@PathVariable Long id, @RequestBody ZoneCollectDto zoneDto) {
        ZoneCollectDto updated = zoneService.update(id, zoneDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        zoneService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        zoneService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<ZoneCollectDto>> findAllIncludingDeleted() {
        List<ZoneCollectDto> zones = zoneService.findAllIncludingDeleted();
        return ResponseEntity.ok(zones);
    }
}
