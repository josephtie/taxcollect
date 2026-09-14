package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.CarteContribuable;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.enums.CarteStatus;
import com.nectuxingenieries.collect.tax.models.enums.CarteType;
import com.nectuxingenieries.collect.tax.models.enums.QRSecurityLevel;
import com.nectuxingenieries.collect.tax.repositories.CarteContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/taxcollect/carte-contribuable")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Cartes Contribuable", description = "API de gestion des cartes de contribuables")
public class CarteContribuableController {

    private final CarteContribuableRepository carteRepository;
    private final ContribuableRepository contribuableRepository;
    private final SecureRandom random = new SecureRandom();

    public CarteContribuableController(CarteContribuableRepository carteRepository,
                                       ContribuableRepository contribuableRepository) {
        this.carteRepository = carteRepository;
        this.contribuableRepository = contribuableRepository;
    }

    @PostMapping
    @Operation(summary = "Créer une nouvelle carte pour un contribuable")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<Map<String, Object>> createCarte(@RequestBody Map<String, Object> body) {
        Long contribuableId = parseLong(body.get("contribuableId"));
        if (contribuableId == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "contribuableId est requis"));
        }

        Contribuable contribuable = contribuableRepository.findById(contribuableId).orElse(null);
        if (contribuable == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Contribuable non trouvé: " + contribuableId));
        }

        // Désactiver l'ancienne carte active si elle existe
        carteRepository.findActiveByContribuable(contribuableId, CarteStatus.ACTIVE)
                .ifPresent(ancienne -> {
                    ancienne.setStatus(CarteStatus.EXPIRED);
                    carteRepository.save(ancienne);
                });

        CarteContribuable carte = new CarteContribuable();
        carte.setContribuable(contribuable);
        carte.setNumeroCarte(generateNumeroCarte());
        carte.setMatriculeUnique(generateMatricule());
        carte.setType(CarteType.fromCode((String) body.getOrDefault("type", "pvc")));
        carte.setStatus(CarteStatus.ACTIVE);
        carte.setSecurityLevel(QRSecurityLevel.fromCode((String) body.getOrDefault("securityLevel", "standard")));
        carte.setDateEmission(LocalDateTime.now());

        // Date d'expiration : 1 an par défaut, ou valeur fournie
        String dateExpirationStr = (String) body.get("dateExpiration");
        if (dateExpirationStr != null && !dateExpirationStr.isEmpty()) {
            carte.setDateExpiration(LocalDateTime.parse(dateExpirationStr));
        } else {
            carte.setDateExpiration(LocalDateTime.now().plusDays(365));
        }

        carte.setAgentId((String) body.get("agentId"));
        carte.setZoneId((String) body.get("zoneId"));
        carte.setSynced(true);

        CarteContribuable saved = carteRepository.save(carte);
        return ResponseEntity.status(HttpStatus.CREATED).body(toDto(saved));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer une carte par ID")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<Map<String, Object>> getCarteById(@PathVariable Long id) {
        return carteRepository.findById(id)
                .map(c -> ResponseEntity.ok(toDto(c)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/matricule/{matricule}")
    @Operation(summary = "Récupérer une carte par matricule unique")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<Map<String, Object>> getCarteByMatricule(@PathVariable String matricule) {
        return carteRepository.findByMatriculeUnique(matricule)
                .map(c -> ResponseEntity.ok(toDto(c)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/contribuable/{contribuableId}")
    @Operation(summary = "Récupérer toutes les cartes d'un contribuable")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<List<Map<String, Object>>> getCartesByContribuable(@PathVariable Long contribuableId) {
        List<CarteContribuable> cartes = carteRepository.findByContribuableId(contribuableId);
        return ResponseEntity.ok(cartes.stream().map(this::toDto).collect(Collectors.toList()));
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "Mettre à jour le statut d'une carte")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT', 'RESPONSABLE_QUARTIER')")
    public ResponseEntity<Map<String, Object>> updateCarteStatus(
            @PathVariable Long id, @RequestBody Map<String, String> body) {
        String statusCode = body.get("status");
        if (statusCode == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "status est requis"));
        }

        CarteStatus newStatus = CarteStatus.fromCode(statusCode);
        return carteRepository.findById(id)
                .map(carte -> {
                    carte.setStatus(newStatus);
                    carteRepository.save(carte);
                    return ResponseEntity.ok(toDto(carte));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/statistics")
    @Operation(summary = "Statistiques des cartes contribuables")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        long total = carteRepository.count();
        long actives = carteRepository.countByStatus(CarteStatus.ACTIVE);
        long expirees = carteRepository.countByStatus(CarteStatus.EXPIRED);
        long suspendues = carteRepository.countByStatus(CarteStatus.SUSPENDED);
        long revokes = carteRepository.countByStatus(CarteStatus.REVOKED);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime in30Days = now.plusDays(30);
        long expirantDans30Jours = carteRepository.findByDateExpirationBefore(in30Days).stream()
                .filter(c -> c.getStatus() == CarteStatus.ACTIVE && c.getDateExpiration().isAfter(now))
                .count();

        LocalDateTime debutJour = now.toLocalDate().atStartOfDay();
        long emisesAujourdhui = carteRepository.findByDateEmissionBetween(debutJour, now).size();

        long nonSynchronisees = carteRepository.findBySyncedFalse().size();

        // Répartition par type
        Map<String, Long> repartitionParType = new LinkedHashMap<>();
        for (CarteType type : CarteType.values()) {
            repartitionParType.put(type.getCode(), carteRepository.findAll().stream()
                    .filter(c -> c.getType() == type).count());
        }

        // Répartition par statut
        Map<String, Long> repartitionParStatut = new LinkedHashMap<>();
        for (CarteStatus status : CarteStatus.values()) {
            repartitionParStatut.put(status.getCode(), carteRepository.countByStatus(status));
        }

        // Cartes récentes (10 dernières)
        List<Map<String, Object>> recentesCartes = carteRepository.findAll().stream()
                .sorted(Comparator.comparing(CarteContribuable::getDateEmission).reversed())
                .limit(10)
                .map(this::toDto)
                .collect(Collectors.toList());

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalCartes", total);
        stats.put("cartesActives", actives);
        stats.put("cartesExpirees", expirees);
        stats.put("cartesSuspendues", suspendues);
        stats.put("cartesExpirantDans30Jours", expirantDans30Jours);
        stats.put("cartesEmisesAujourdhui", emisesAujourdhui);
        stats.put("cartesNonSynchronisees", nonSynchronisees);
        stats.put("cartesRevokes", revokes);
        stats.put("repartitionParType", repartitionParType);
        stats.put("repartitionParStatut", repartitionParStatut);
        stats.put("repartitionParZone", Map.of());
        stats.put("recentesCartes", recentesCartes);

        return ResponseEntity.ok(stats);
    }

    // ─── Helpers ──────────────────────────────────────────────────

    private String generateNumeroCarte() {
        int year = LocalDateTime.now().getYear();
        int suffix = random.nextInt(999999);
        return String.format("CRT-%d-%06d", year, suffix);
    }

    private String generateMatricule() {
        int year = LocalDateTime.now().getYear();
        int suffix = random.nextInt(99999999);
        return String.format("MAT-%d-%08d", year, suffix);
    }

    private Long parseLong(Object value) {
        if (value == null) return null;
        if (value instanceof Number) return ((Number) value).longValue();
        try {
            return Long.parseLong(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Map<String, Object> toDto(CarteContribuable carte) {
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("id", String.valueOf(carte.getId()));
        dto.put("contribuableId", String.valueOf(carte.getContribuable().getId()));
        dto.put("numeroCarte", carte.getNumeroCarte());
        dto.put("matriculeUnique", carte.getMatriculeUnique());
        dto.put("qrCodeData", carte.getQrCodeData() != null ? carte.getQrCodeData() : "");
        dto.put("type", carte.getType().getCode());
        dto.put("status", carte.getStatus().getCode());
        dto.put("securityLevel", carte.getSecurityLevel().getCode());
        dto.put("dateEmission", carte.getDateEmission().toString());
        dto.put("dateExpiration", carte.getDateExpiration().toString());
        dto.put("photoUrl", carte.getPhotoUrl());
        dto.put("agentId", carte.getAgentId());
        dto.put("zoneId", carte.getZoneId());
        dto.put("metadata", null);
        dto.put("createdAt", carte.getCreatedAt() != null ? carte.getCreatedAt().toString() : LocalDateTime.now().toString());
        dto.put("updatedAt", carte.getUpdatedAt() != null ? carte.getUpdatedAt().toString() : null);
        return dto;
    }
}
