package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.AgentSummaryDto;
import com.nectuxingenieries.collect.tax.dto.SupervisedZoneDto;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.services.SupervisionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/taxcollect/supervision")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Supervision", description = "API de supervision des zones et affectation des agents")
public class SupervisionController {

    private final SupervisionService supervisionService;

    public SupervisionController(SupervisionService supervisionService) {
        this.supervisionService = supervisionService;
    }

    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            Jwt jwt = jwtAuth.getToken();
            return jwt.getClaim("sub");
        }
        throw new IllegalStateException("Utilisateur non authentifié");
    }

    @GetMapping("/zones/supervised")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Récupérer les zones supervisées par l'utilisateur courant")
    public ResponseEntity<List<SupervisedZoneDto>> getSupervisedZones() {
        String superviseurId = getCurrentUserId();
        List<SupervisedZoneDto> zones = supervisionService.getSupervisedZones(superviseurId);
        return ResponseEntity.ok(zones);
    }

    @GetMapping("/agents/available")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Récupérer les agents disponibles pour affectation")
    public ResponseEntity<List<AgentSummaryDto>> getAvailableAgents() {
        String superviseurId = getCurrentUserId();
        List<AgentSummaryDto> agents = supervisionService.getAvailableAgents(superviseurId);
        return ResponseEntity.ok(agents);
    }

    @PostMapping("/assign-agent")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Affecter un agent à une zone")
    public ResponseEntity<Void> assignAgentToZone(@RequestBody Map<String, Long> body) {
        Long zoneId = body.get("zoneId");
        Long agentId = body.get("agentId");
        if (zoneId == null || agentId == null) {
            return ResponseEntity.badRequest().build();
        }
        supervisionService.assignAgentToZone(zoneId, agentId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/unassign-agent/{zoneId}/{agentId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Retirer un agent d'une zone")
    public ResponseEntity<Void> unassignAgentFromZone(@PathVariable Long zoneId, @PathVariable Long agentId) {
        supervisionService.unassignAgentFromZone(zoneId, agentId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/zones/{zoneId}/assign-superviseur")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Affecter une zone à un superviseur")
    public ResponseEntity<ZoneDto> assignZoneToSuperviseur(@PathVariable Long zoneId, @RequestBody Map<String, String> body) {
        String superviseurId = body.get("superviseurId");
        if (superviseurId == null) {
            return ResponseEntity.badRequest().build();
        }
        if (superviseurId.trim().isEmpty()) {
            superviseurId = null;
        }
        ZoneDto zone = supervisionService.assignZoneToSuperviseur(zoneId, superviseurId);
        return ResponseEntity.ok(zone);
    }

    @GetMapping("/zones/unassigned")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Récupérer les zones non assignées au superviseur courant")
    public ResponseEntity<List<ZoneDto>> getUnassignedZones() {
        String superviseurId = getCurrentUserId();
        List<ZoneDto> zones = supervisionService.getUnassignedZones(superviseurId);
        return ResponseEntity.ok(zones);
    }
}
