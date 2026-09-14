package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.SignalementDto;
import com.nectuxingenieries.collect.tax.services.SignalementService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/signalement")
@RequiredArgsConstructor
@Tag(name = "Signalements", description = "API de gestion des signalements agent")
public class SignalementController {

    private final SignalementService signalementService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<SignalementDto>> findAll() {
        return ResponseEntity.ok(signalementService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SignalementDto> findById(@PathVariable Long id) {
        return signalementService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<SignalementDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(signalementService.findByAgentId(agentId));
    }

    @GetMapping("/statut/{statut}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<SignalementDto>> findByStatut(@PathVariable String statut) {
        return ResponseEntity.ok(signalementService.findByStatut(statut));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<SignalementDto> create(@RequestBody SignalementDto signalementDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(signalementService.create(signalementDto));
    }

    @PostMapping("/{id}/traiter")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<SignalementDto> traiter(
            @PathVariable Long id,
            @RequestParam String reponse,
            @RequestParam Long traitePar) {
        return ResponseEntity.ok(signalementService.traiter(id, reponse, traitePar));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        signalementService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
