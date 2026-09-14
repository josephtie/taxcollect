package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.SyncItemDto;
import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import com.nectuxingenieries.collect.tax.services.SyncItemService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/sync")
@RequiredArgsConstructor
@Tag(name = "Synchronisation", description = "API de gestion de la file de synchronisation")
public class SyncItemController {

    private final SyncItemService syncItemService;

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<SyncItemDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(syncItemService.findByAgentId(agentId));
    }

    @GetMapping("/agent/{agentId}/statut/{statut}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<SyncItemDto>> findByAgentAndStatut(
            @PathVariable Long agentId, @PathVariable StatutSyncItem statut) {
        return ResponseEntity.ok(syncItemService.findByAgentIdAndStatut(agentId, statut));
    }

    @GetMapping("/statut/{statut}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<SyncItemDto>> findByStatut(@PathVariable StatutSyncItem statut) {
        return ResponseEntity.ok(syncItemService.findByStatut(statut));
    }

    @GetMapping("/agent/{agentId}/pending/count")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Long> countPending(@PathVariable Long agentId) {
        return ResponseEntity.ok(syncItemService.countPendingByAgentId(agentId));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SyncItemDto> findById(@PathVariable Long id) {
        return syncItemService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SyncItemDto> create(@RequestBody SyncItemDto syncItemDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(syncItemService.create(syncItemDto));
    }

    @PostMapping("/{id}/synced")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> markSynced(@PathVariable Long id) {
        syncItemService.markSynced(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/failed")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> markFailed(@PathVariable Long id, @RequestParam String error) {
        syncItemService.markFailed(id, error);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        syncItemService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
