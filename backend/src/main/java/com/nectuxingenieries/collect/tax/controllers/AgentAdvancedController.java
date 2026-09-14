package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.*;
import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("api/taxcollect/agent-advanced")
@RequiredArgsConstructor
@Tag(name = "Agent Avancé", description = "API Phase 3: stats avancées, itinéraire, QR, conflits")
public class AgentAdvancedController {

    private final TransactionRepository transactionRepository;
    private final VisiteRepository visiteRepository;
    private final TourneeRepository tourneeRepository;
    private final ContribuableRepository contribuableRepository;
    private final SyncItemRepository syncItemRepository;
    private final NotificationRepository notificationRepository;

    // --- 19. Statistiques avancées ---

    @GetMapping("/stats/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<AgentStatsDto> getStats(
            @PathVariable Long agentId,
            @RequestParam(defaultValue = "JOUR") String period) {

        LocalDateTime debut;
        LocalDateTime fin = LocalDateTime.now();
        switch (period.toUpperCase()) {
            case "SEMAINE":
                debut = LocalDate.now().with(DayOfWeek.MONDAY).atStartOfDay();
                break;
            case "MOIS":
                debut = LocalDate.now().withDayOfMonth(1).atStartOfDay();
                break;
            default:
                debut = LocalDate.now().atStartOfDay();
        }

        AgentStatsDto dto = new AgentStatsDto();
        dto.setPeriod(period.toUpperCase());

        List<Transaction> transactions = transactionRepository
                .findTransactionsByAgentAndDateRange(agentId, debut, fin);

        dto.setNbTransactions(transactions.size());
        dto.setMontantCollecte(transactions.stream()
                .filter(t -> t.getStatut() == StatutTransaction.VALIDEE || t.getStatut() == StatutTransaction.SUCCESS)
                .map(Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        dto.setMontantEspece(transactions.stream()
                .filter(t -> t.getStatut() == StatutTransaction.VALIDEE || t.getStatut() == StatutTransaction.SUCCESS)
                .filter(t -> t.getModePaiement() != null && t.getModePaiement().name().equals("ESPECES"))
                .map(Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        dto.setMontantMobileMoney(transactions.stream()
                .filter(t -> t.getStatut() == StatutTransaction.VALIDEE || t.getStatut() == StatutTransaction.SUCCESS)
                .filter(t -> t.getModePaiement() != null && !t.getModePaiement().name().equals("ESPECES"))
                .map(Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        List<Transaction> impayes = transactions.stream()
                .filter(t -> t.getStatut() == StatutTransaction.EN_ATTENTE)
                .collect(Collectors.toList());
        dto.setNbPaiementsPartiels(impayes.size());
        dto.setMontantImpayes(impayes.stream()
                .map(Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        dto.setMontantAttendu(transactions.stream()
                .map(Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        if (dto.getMontantAttendu().compareTo(BigDecimal.ZERO) > 0) {
            dto.setTauxRecouvrement(dto.getMontantCollecte()
                    .divide(dto.getMontantAttendu(), 4, java.math.RoundingMode.HALF_UP)
                    .doubleValue() * 100);
        }

        List<Visite> visites = visiteRepository.findByTourneeId(agentId).stream()
                .filter(v -> v.getDateVisite() != null && v.getDateVisite().isAfter(debut))
                .collect(Collectors.toList());
        dto.setNbVisites(visites.size());
        dto.setNbVisitesPayees((int) visites.stream()
                .filter(v -> v.getStatut() != null && v.getStatut().name().equals("PAYE"))
                .count());
        dto.setNbVisitesImpayees((int) visites.stream()
                .filter(v -> v.getStatut() != null && v.getStatut().name().equals("IMPAYE"))
                .count());
        dto.setNbVisitesAbsentes((int) visites.stream()
                .filter(v -> v.getStatut() != null && v.getStatut().name().equals("ABSENT"))
                .count());

        if (dto.getNbVisites() > 0) {
            dto.setTauxReussite((double) dto.getNbVisitesPayees() / dto.getNbVisites() * 100);
        }

        dto.setNbNouveauxContribuables(Math.toIntExact(contribuableRepository
                .countByCreatedAtBetween(debut, fin)));

        return ResponseEntity.ok(dto);
    }

    // --- 20. Optimisation d'itinéraire (nearest neighbor) ---

    @GetMapping("/itineraire/{tourneeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<ItineraireOptimiseDto> optimizeItineraire(
            @PathVariable Long tourneeId,
            @RequestParam(required = false) Double startLat,
            @RequestParam(required = false) Double startLng) {

        Tournee tournee = tourneeRepository.findById(tourneeId)
                .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));

        List<Visite> visites = visiteRepository.findByTourneeId(tourneeId);
        List<Contribuable> contribuables = visites.stream()
                .map(Visite::getContribuable)
                .filter(Objects::nonNull)
                .filter(c -> c.getLatitude() != null && c.getLongitude() != null)
                .collect(Collectors.toList());

        if (contribuables.isEmpty()) {
            ItineraireOptimiseDto empty = new ItineraireOptimiseDto();
            empty.setTourneeId(tourneeId);
            empty.setEtapes(Collections.emptyList());
            return ResponseEntity.ok(empty);
        }

        double currentLat = startLat != null ? startLat : contribuables.get(0).getLatitude();
        double currentLng = startLng != null ? startLng : contribuables.get(0).getLongitude();

        List<Contribuable> remaining = new ArrayList<>(contribuables);
        List<ItineraireOptimiseDto.EtapeItineraire> etapes = new ArrayList<>();
        double totalDistance = 0;
        int ordre = 1;

        while (!remaining.isEmpty()) {
            Contribuable nearest = null;
            double minDist = Double.MAX_VALUE;
            for (Contribuable c : remaining) {
                double d = haversineKm(currentLat, currentLng, c.getLatitude(), c.getLongitude());
                if (d < minDist) {
                    minDist = d;
                    nearest = c;
                }
            }
            if (nearest != null) {
                ItineraireOptimiseDto.EtapeItineraire etape = new ItineraireOptimiseDto.EtapeItineraire();
                etape.setOrdre(ordre++);
                etape.setContribuableId(nearest.getId());
                etape.setNom(nearest.getNom());
                etape.setAdresse(nearest.getAdresse());
                etape.setLatitude(nearest.getLatitude());
                etape.setLongitude(nearest.getLongitude());
                etape.setDistanceDepuisPrecedentKm(minDist);
                etapes.add(etape);
                totalDistance += minDist;
                currentLat = nearest.getLatitude();
                currentLng = nearest.getLongitude();
                remaining.remove(nearest);
            }
        }

        ItineraireOptimiseDto dto = new ItineraireOptimiseDto();
        dto.setTourneeId(tourneeId);
        dto.setPointDepart(startLat != null ? startLat + "," + startLng : "Premier contribuable");
        dto.setEtapes(etapes);
        dto.setDistanceTotaleKm(totalDistance);
        dto.setDureeEstimeeMinutes((int) (totalDistance * 3));
        return ResponseEntity.ok(dto);
    }

    // --- 23. Vérification reçu par QR ---

    @GetMapping("/verify-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<RecuVerificationDto> verifyQr(@RequestParam String qrData) {
        Transaction transaction = transactionRepository.findByNumeroRecu(qrData)
                .orElseGet(() -> transactionRepository.findByHashTransaction(qrData)
                        .orElse(null));

        RecuVerificationDto dto = new RecuVerificationDto();
        List<String> anomalies = new ArrayList<>();

        if (transaction == null) {
            dto.setValide(false);
            anomalies.add("Reçu non trouvé dans le système");
            dto.setAnomalies(anomalies);
            return ResponseEntity.ok(dto);
        }

        dto.setValide(true);
        dto.setNumeroRecu(transaction.getNumeroRecu());
        dto.setHashTransaction(transaction.getHashTransaction());
        dto.setTransactionId(transaction.getId());
        dto.setMontant(transaction.getMontant());
        dto.setModePaiement(transaction.getModePaiement() != null ? transaction.getModePaiement().name() : null);
        dto.setStatut(transaction.getStatut() != null ? transaction.getStatut().name() : null);
        dto.setDateCreation(transaction.getDateCreation());

        if (transaction.getContribuable() != null) {
            dto.setContribuableNom(transaction.getContribuable().getNom());
            dto.setContribuablePrenom(transaction.getContribuable().getPrenom());
        }
        if (transaction.getAgent() != null) {
            dto.setAgentNom(transaction.getAgent().getNom());
        }
        if (transaction.getZone() != null) {
            dto.setZoneNom(transaction.getZone().getNom());
        }

        if (transaction.getStatut() == StatutTransaction.EN_ATTENTE) {
            anomalies.add("Paiement en attente de confirmation");
        }
        if (transaction.getOffline()) {
            anomalies.add("Transaction hors ligne - non synchronisée");
        }

        dto.setAnomalies(anomalies);
        return ResponseEntity.ok(dto);
    }

    // --- 24. Gestion des conflits ---

    @GetMapping("/conflicts/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<SyncItemDto>> getConflicts(@PathVariable Long agentId) {
        List<SyncItem> conflicts = syncItemRepository.findByAgentIdAndStatut(agentId, StatutSyncItem.CONFLICT);
        List<SyncItemDto> dtos = conflicts.stream().map(s -> {
            SyncItemDto dto = new SyncItemDto();
            dto.setId(s.getId());
            dto.setAgentId(s.getAgentId());
            dto.setEntityType(s.getEntityType());
            dto.setEntityId(s.getEntityId());
            dto.setLocalId(s.getLocalId());
            dto.setStatut(s.getStatut());
            dto.setAction(s.getAction());
            dto.setPayload(s.getPayload());
            dto.setErrorMessage(s.getErrorMessage());
            dto.setRetryCount(s.getRetryCount());
            dto.setLastSyncAttempt(s.getLastSyncAttempt());
            dto.setSyncedAt(s.getSyncedAt());
            return dto;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @PostMapping("/conflicts/resolve")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> resolveConflict(@RequestBody ConflictResolutionDto resolution) {
        SyncItem item = syncItemRepository.findById(resolution.getSyncItemId())
                .orElseThrow(() -> new RuntimeException("SyncItem non trouvé"));

        switch (resolution.getResolution().toUpperCase()) {
            case "KEEP_LOCAL":
                item.setStatut(StatutSyncItem.SYNCING);
                item.setErrorMessage(null);
                break;
            case "KEEP_SERVER":
                item.setStatut(StatutSyncItem.SYNCED);
                item.setSyncedAt(LocalDateTime.now());
                item.setErrorMessage(null);
                break;
            case "KEEP_BOTH":
                item.setStatut(StatutSyncItem.SYNCED);
                item.setSyncedAt(LocalDateTime.now());
                item.setErrorMessage("Conflit résolu: les deux versions ont été conservées");
                break;
            case "DISCARD":
                item.setStatut(StatutSyncItem.SYNCED);
                item.setSyncedAt(LocalDateTime.now());
                item.setErrorMessage("Conflit résolu: version locale ignorée");
                break;
            default:
                throw new RuntimeException("Résolution inconnue: " + resolution.getResolution());
        }

        syncItemRepository.save(item);
        return ResponseEntity.ok().build();
    }

    private double haversineKm(double lat1, double lng1, double lat2, double lng2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
