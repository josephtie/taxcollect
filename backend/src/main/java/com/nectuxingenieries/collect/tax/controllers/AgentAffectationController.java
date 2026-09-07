package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.AgentAffectationDto;
import com.nectuxingenieries.collect.tax.dto.EffectivePerimeterDto;
import com.nectuxingenieries.collect.tax.models.TerritoryType;
import com.nectuxingenieries.collect.tax.services.AgentAffectationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/affectation")
@RequiredArgsConstructor
@Tag(name = "Affectations", description = "API de gestion des affectations d'agents sur le territoire")
public class AgentAffectationController {

    private final AgentAffectationService affectationService;

    @PostMapping("/assign")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Affecter un agent à un territoire (Zone, Quartier ou Secteur)")
    public ResponseEntity<AgentAffectationDto> assign(
            @RequestParam Long agentId,
            @RequestParam TerritoryType territoryType,
            @RequestParam Long territoryId) {
        AgentAffectationDto dto = affectationService.assign(agentId, territoryType, territoryId);
        return ResponseEntity.status(HttpStatus.CREATED).body(dto);
    }

    @DeleteMapping("/unassign")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @Operation(summary = "Retirer un agent d'un territoire")
    public ResponseEntity<Void> unassign(
            @RequestParam Long agentId,
            @RequestParam TerritoryType territoryType,
            @RequestParam Long territoryId) {
        affectationService.unassign(agentId, territoryType, territoryId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/territory")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    @Operation(summary = "Lister les affectations actives pour un territoire")
    public ResponseEntity<List<AgentAffectationDto>> getByTerritory(
            @RequestParam TerritoryType territoryType,
            @RequestParam Long territoryId) {
        return ResponseEntity.ok(affectationService.getAffectationsByTerritory(territoryType, territoryId));
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    @Operation(summary = "Lister les affectations actives d'un agent")
    public ResponseEntity<List<AgentAffectationDto>> getByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(affectationService.getAffectationsByAgent(agentId));
    }

    @GetMapping("/agent/{agentId}/perimeter")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    @Operation(summary = "Calculer le périmètre effectif d'un agent (héritage hiérarchique)")
    public ResponseEntity<EffectivePerimeterDto> getEffectivePerimeter(@PathVariable Long agentId) {
        return ResponseEntity.ok(affectationService.getEffectivePerimeter(agentId));
    }
}
