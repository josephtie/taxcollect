package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.AgentDashboardDto;
import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("api/taxcollect/agent")
@RequiredArgsConstructor
@Tag(name = "Agent Dashboard", description = "API tableau de bord agent de terrain")
public class AgentDashboardController {

    private final TransactionRepository transactionRepository;
    private final TourneeRepository tourneeRepository;
    private final VisiteRepository visiteRepository;
    private final PortefeuilleRepository portefeuilleRepository;
    private final PromessePaiementRepository promessePaiementRepository;
    private final NotificationRepository notificationRepository;
    private final ContribuableRepository contribuableRepository;

    @GetMapping("/dashboard/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<AgentDashboardDto> getDashboard(@PathVariable Long agentId) {
        AgentDashboardDto dto = new AgentDashboardDto();
        dto.setAgentId(agentId);

        LocalDateTime debutJour = LocalDate.now().atStartOfDay();
        LocalDateTime finJour = LocalDateTime.now();
        LocalDateTime debutMois = LocalDate.now().withDayOfMonth(1).atStartOfDay();

        dto.setNbVisitesJour((int) visiteRepository.findByTourneeId(agentId).stream()
                .filter(v -> v.getDateVisite() != null && v.getDateVisite().isAfter(debutJour))
                .count());

        List<com.nectuxingenieries.collect.tax.models.Tournee> tournees = tourneeRepository.findByAgentId(agentId);
        dto.setNbVisitesMois(tournees.stream()
                .filter(t -> t.getDateTournee() != null && t.getDateTournee().getMonth() == LocalDate.now().getMonth())
                .mapToInt(t -> t.getNbVisitesEffectuees() != null ? t.getNbVisitesEffectuees() : 0)
                .sum());

        BigDecimal collecteJour = transactionRepository.sumMontantByDateRange(debutJour, finJour);
        BigDecimal collecteMois = transactionRepository.sumMontantByDateRange(debutMois, finJour);
        dto.setMontantCollecteJour(collecteJour != null ? collecteJour : BigDecimal.ZERO);
        dto.setMontantCollecteMois(collecteMois != null ? collecteMois : BigDecimal.ZERO);

        List<com.nectuxingenieries.collect.tax.models.Transaction> impayes =
                transactionRepository.findByAgentIdAndStatut(agentId, StatutTransaction.EN_ATTENTE);
        dto.setNbImpayes(impayes.size());
        dto.setMontantImpayes(impayes.stream()
                .map(com.nectuxingenieries.collect.tax.models.Transaction::getMontant)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        dto.setNbPromessesEnAttente((int) promessePaiementRepository.findByStatut("EN_ATTENTE").stream()
                .filter(p -> p.getAgent() != null && p.getAgent().getId().equals(agentId))
                .count());

        dto.setNbNotificationsNonLues((int) notificationRepository.countUnreadByAgentId(agentId));
        dto.setNbPortefeuille(portefeuilleRepository.findActiveByAgentId(agentId).size());
        dto.setNbContribuablesAvecGps(contribuableRepository.findContribuablesWithCoordinates().size());

        List<com.nectuxingenieries.collect.tax.models.Transaction> offlineTx =
                transactionRepository.findByOfflineTrue();
        dto.setNbTransactionsOffline(offlineTx.size());

        return ResponseEntity.ok(dto);
    }

    @GetMapping("/impayes/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<Map<String, Object>>> getImpayes(@PathVariable Long agentId) {
        List<com.nectuxingenieries.collect.tax.models.Transaction> impayes =
                transactionRepository.findByAgentIdAndStatut(agentId, StatutTransaction.EN_ATTENTE);
        List<Map<String, Object>> result = impayes.stream().map(t -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", t.getId());
            map.put("numeroRecu", t.getNumeroRecu());
            map.put("montant", t.getMontant());
            map.put("contribuableId", t.getContribuable() != null ? t.getContribuable().getId() : null);
            map.put("contribuableNom", t.getContribuable() != null ? t.getContribuable().getNom() : null);
            map.put("dateCreation", t.getDateCreation());
            map.put("statut", t.getStatut());
            return map;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/nearby/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<ContribuableDto>> getNearbyContribuables(
            @PathVariable Long agentId,
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "500") double radiusMeters) {
        List<Contribuable> contribuables = contribuableRepository.findContribuablesWithinRadius(latitude, longitude, radiusMeters);
        List<ContribuableDto> dtos = contribuables.stream().map(c -> {
            ContribuableDto dto = new ContribuableDto();
            dto.setId(c.getId());
            dto.setNom(c.getNom());
            dto.setPrenom(c.getPrenom());
            dto.setTelephone(c.getTelephone());
            dto.setAdresse(c.getAdresse());
            dto.setLatitude(c.getLatitude());
            dto.setLongitude(c.getLongitude());
            dto.setActivite(c.getActivite());
            dto.setQuartier(c.getQuartier());
            return dto;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }
}
