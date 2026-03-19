package com.nectuxingenieries.collect.tax.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/taxcollect/supervision")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
public class SupervisionController {

    @GetMapping("/agents/available")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    public ResponseEntity<List<Map<String, Object>>> getAvailableAgents() {
        // Retourner une liste d'agents disponibles pour la supervision
        List<Map<String, Object>> agents = List.of(
            Map.of(
                "id", 1L,
                "nom", "Agent 1",
                "prenom", "Doe",
                "email", "agent1@example.com",
                "telephone", "771234567",
                "statut", "ACTIF",
                "enLigne", true
            ),
            Map.of(
                "id", 2L,
                "nom", "Agent 2", 
                "prenom", "Smith",
                "email", "agent2@example.com",
                "telephone", "775678901",
                "statut", "ACTIF",
                "enLigne", false
            )
        );
        
        return ResponseEntity.ok(agents);
    }

    @GetMapping("/zones/supervised")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    public ResponseEntity<List<Map<String, Object>>> getSupervisedZones() {
        // Retourner une liste de zones supervisées
        List<Map<String, Object>> zones = List.of(
            Map.of(
                "id", 1L,
                "nom", "Zone Centre",
                "statut", true,
                "agentsCount", 2,
                "quartier", Map.of("id", 1L, "nom", "Centre-ville")
            ),
            Map.of(
                "id", 2L,
                "nom", "Zone Nord",
                "statut", true,
                "agentsCount", 1,
                "quartier", Map.of("id", 2L, "nom", "Nord-ville")
            )
        );
        
        return ResponseEntity.ok(zones);
    }
}
