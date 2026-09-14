package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.AuditEntryDto;
import com.nectuxingenieries.collect.tax.models.enums.TypeAudit;
import com.nectuxingenieries.collect.tax.services.AuditEntryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("api/taxcollect/audit")
@RequiredArgsConstructor
@Tag(name = "Audit", description = "API de gestion du journal d'activité agent")
public class AuditEntryController {

    private final AuditEntryService auditEntryService;

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<AuditEntryDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(auditEntryService.findByAgentId(agentId));
    }

    @GetMapping("/agent/{agentId}/since")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<AuditEntryDto>> findByAgentSince(
            @PathVariable Long agentId,
            @RequestParam LocalDateTime since) {
        return ResponseEntity.ok(auditEntryService.findByAgentIdSince(agentId, since));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<AuditEntryDto> findById(@PathVariable Long id) {
        return auditEntryService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/pending-sync")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<AuditEntryDto>> findPendingSync() {
        return ResponseEntity.ok(auditEntryService.findPendingSync());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<AuditEntryDto> create(@RequestBody AuditEntryDto auditEntryDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(auditEntryService.create(auditEntryDto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        auditEntryService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/entity/{entityType}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par type d'entité")
    public ResponseEntity<List<AuditEntryDto>> findByEntityType(@PathVariable String entityType) {
        return ResponseEntity.ok(auditEntryService.findByEntityType(entityType));
    }

    @GetMapping("/entity/{entityType}/{entityId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par entité spécifique")
    public ResponseEntity<List<AuditEntryDto>> findByEntityTypeAndEntityId(
            @PathVariable String entityType, @PathVariable Long entityId) {
        return ResponseEntity.ok(auditEntryService.findByEntityTypeAndEntityId(entityType, entityId));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par utilisateur")
    public ResponseEntity<List<AuditEntryDto>> findByUserId(@PathVariable String userId) {
        return ResponseEntity.ok(auditEntryService.findByUserId(userId));
    }

    @GetMapping("/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par plage de dates")
    public ResponseEntity<List<AuditEntryDto>> findByDateRange(
            @RequestParam LocalDateTime debut, @RequestParam LocalDateTime fin) {
        return ResponseEntity.ok(auditEntryService.findByDateRange(debut, fin));
    }

    @GetMapping("/zone/{zoneId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par zone")
    public ResponseEntity<List<AuditEntryDto>> findByZoneId(@PathVariable Long zoneId) {
        return ResponseEntity.ok(auditEntryService.findByZoneId(zoneId));
    }

    @GetMapping("/quartier/{quartierId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
    @Operation(summary = "Rechercher les audits par quartier")
    public ResponseEntity<List<AuditEntryDto>> findByQuartierId(@PathVariable Long quartierId) {
        return ResponseEntity.ok(auditEntryService.findByQuartierId(quartierId));
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Rechercher les audits par type")
    public ResponseEntity<List<AuditEntryDto>> findByType(@PathVariable TypeAudit type) {
        return ResponseEntity.ok(auditEntryService.findByType(type));
    }
}
