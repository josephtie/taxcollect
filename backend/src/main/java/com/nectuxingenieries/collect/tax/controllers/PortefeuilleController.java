package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.PortefeuilleDto;
import com.nectuxingenieries.collect.tax.services.PortefeuilleService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/portefeuille")
@RequiredArgsConstructor
@Tag(name = "Portefeuille", description = "API de gestion du portefeuille d'agents")
public class PortefeuilleController {

    private final PortefeuilleService portefeuilleService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<PortefeuilleDto>> findAll() {
        return ResponseEntity.ok(portefeuilleService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<PortefeuilleDto> findById(@PathVariable Long id) {
        return portefeuilleService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<PortefeuilleDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(portefeuilleService.findByAgentId(agentId));
    }

    @GetMapping("/contribuable/{contribuableId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<PortefeuilleDto>> findByContribuable(@PathVariable Long contribuableId) {
        return ResponseEntity.ok(portefeuilleService.findByContribuableId(contribuableId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<PortefeuilleDto> create(@RequestBody PortefeuilleDto portefeuilleDto) {
        PortefeuilleDto created = portefeuilleService.create(portefeuilleDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<PortefeuilleDto> update(@PathVariable Long id, @RequestBody PortefeuilleDto portefeuilleDto) {
        return ResponseEntity.ok(portefeuilleService.update(id, portefeuilleDto));
    }

    @PostMapping("/{id}/desaffecter")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> desaffecter(@PathVariable Long id) {
        portefeuilleService.desaffecter(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        portefeuilleService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        portefeuilleService.restore(id);
        return ResponseEntity.ok().build();
    }
}
