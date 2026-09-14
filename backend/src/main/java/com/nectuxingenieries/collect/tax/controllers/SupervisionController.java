package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.*;
import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.repositories.*;
import com.nectuxingenieries.collect.tax.services.AnomalieService;
import com.nectuxingenieries.collect.tax.services.AuditEntryService;
import com.nectuxingenieries.collect.tax.services.PropositionAffectationService;
import com.nectuxingenieries.collect.tax.services.SupervisionService;
import com.nectuxingenieries.collect.tax.security.TerritorialScopeContext;
import com.nectuxingenieries.collect.tax.models.mappers.ContribuableMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("api/taxcollect/supervision")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Supervision", description = "API de supervision des zones et affectation des agents")
public class SupervisionController {

    private final SupervisionService supervisionService;
    private final ZoneRepository zoneRepository;
    private final QuartierRepository quartierRepository;
    private final SecteurRepository secteurRepository;
    private final AgentRepository agentRepository;
    private final ContribuableRepository contribuableRepository;
    private final TransactionRepository transactionRepository;
    private final AnomalieRepository anomalieRepository;
    private final AnomalieService anomalieService;
    private final PropositionAffectationService propositionService;
    private final AuditEntryService auditEntryService;
    private final TerritorialScopeContext scopeContext;
    private final ContribuableMapper contribuableMapper;

    public SupervisionController(SupervisionService supervisionService,
                                  ZoneRepository zoneRepository,
                                  QuartierRepository quartierRepository,
                                  SecteurRepository secteurRepository,
                                  AgentRepository agentRepository,
                                  ContribuableRepository contribuableRepository,
                                  TransactionRepository transactionRepository,
                                  AnomalieRepository anomalieRepository,
                                  AnomalieService anomalieService,
                                  PropositionAffectationService propositionService,
                                  AuditEntryService auditEntryService,
                                  TerritorialScopeContext scopeContext,
                                  ContribuableMapper contribuableMapper) {
        this.supervisionService = supervisionService;
        this.zoneRepository = zoneRepository;
        this.quartierRepository = quartierRepository;
        this.secteurRepository = secteurRepository;
        this.agentRepository = agentRepository;
        this.contribuableRepository = contribuableRepository;
        this.transactionRepository = transactionRepository;
        this.anomalieRepository = anomalieRepository;
        this.anomalieService = anomalieService;
        this.propositionService = propositionService;
        this.auditEntryService = auditEntryService;
        this.scopeContext = scopeContext;
        this.contribuableMapper = contribuableMapper;
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

    @GetMapping("/my-zone/contribuables")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Récupérer les contribuables des zones du superviseur connecté")
    public ResponseEntity<List<ContribuableDto>> getMyZoneContribuables() {
        String superviseurId = getCurrentUserId();
        List<Zone> zones = zoneRepository.findBySuperviseurId(superviseurId);
        if (zones.isEmpty()) {
            return ResponseEntity.ok(Collections.emptyList());
        }
        List<Long> zoneIds = zones.stream().map(Zone::getId).collect(Collectors.toList());
        List<Contribuable> contribuables = new ArrayList<>();
        for (Long zoneId : zoneIds) {
            contribuables.addAll(contribuableRepository.findByZoneId(zoneId));
        }
        return ResponseEntity.ok(contribuables.stream()
                .map(contribuableMapper::toDto)
                .collect(Collectors.toList()));
    }

    @GetMapping("/my-zone/agents")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Récupérer les collecteurs des zones du superviseur connecté")
    public ResponseEntity<List<AgentSummaryDto>> getMyZoneAgents() {
        String superviseurId = getCurrentUserId();
        List<Zone> zones = zoneRepository.findBySuperviseurId(superviseurId);
        if (zones.isEmpty()) {
            return ResponseEntity.ok(Collections.emptyList());
        }
        List<Long> zoneIds = zones.stream().map(Zone::getId).collect(Collectors.toList());
        List<AgentSummaryDto> result = new ArrayList<>();
        for (Long zoneId : zoneIds) {
            List<Agents> agents = agentRepository.findByZoneId(zoneId);
            for (Agents a : agents) {
                AgentSummaryDto dto = new AgentSummaryDto();
                dto.setId(a.getId());
                dto.setNom(a.getNom());
                dto.setPrenom(a.getPrenom());
                dto.setEmail(a.getEmail());
                dto.setTelephone(a.getTelephone());
                String initials = "";
                if (a.getNom() != null && !a.getNom().isEmpty()) initials += a.getNom().charAt(0);
                if (a.getPrenom() != null && !a.getPrenom().isEmpty()) initials += a.getPrenom().charAt(0);
                dto.setInitials(initials.toUpperCase());
                result.add(dto);
            }
        }
        return ResponseEntity.ok(result);
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
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.AFFECTATION_AGENT,
                "ASSIGN_AGENT_ZONE", "AGENT", agentId,
                "Agent " + agentId + " affecté à la zone " + zoneId,
                scopeContext.getUserId(), scopeContext.getUserRole(), zoneId, null);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/unassign-agent/{zoneId}/{agentId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Retirer un agent d'une zone")
    public ResponseEntity<Void> unassignAgentFromZone(@PathVariable Long zoneId, @PathVariable Long agentId) {
        supervisionService.unassignAgentFromZone(zoneId, agentId);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.RETRAIT_AGENT,
                "UNASSIGN_AGENT_ZONE", "AGENT", agentId,
                "Agent " + agentId + " retiré de la zone " + zoneId,
                scopeContext.getUserId(), scopeContext.getUserRole(), zoneId, null);
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
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.AFFECTATION_RESPONSABLE,
                "ASSIGN_SUPERVISEUR_ZONE", "ZONE", zoneId,
                "Zone " + zoneId + " assignée au superviseur " + superviseurId,
                scopeContext.getUserId(), scopeContext.getUserRole(), zoneId, null);
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

    // ─── A. Tableau de bord de zone ────────────────────────────────

    @GetMapping("/dashboard/{zoneId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Tableau de bord de la zone supervisée")
    public ResponseEntity<ZoneDashboardDto> getZoneDashboard(@PathVariable Long zoneId) {
        Zone zone = zoneRepository.findById(zoneId).orElse(null);
        List<Quartier> quartiers = quartierRepository.findByZoneId(zoneId);
        List<Secteur> allSecteurs = secteurRepository.findByQuartierIdIn(
                quartiers.stream().map(Quartier::getId).collect(Collectors.toList()));
        List<Agents> agents = agentRepository.findByZoneId(zoneId);
        List<Contribuable> contribuables = contribuableRepository.findByZoneId(zoneId);

        ZoneDashboardDto dto = new ZoneDashboardDto();
        dto.setZoneId(zoneId);
        dto.setZoneNom(zone != null ? zone.getNom() : "Zone " + zoneId);
        dto.setNbQuartiers(quartiers.size());
        dto.setNbSecteurs(allSecteurs.size());
        dto.setNbAgents(agents.size());
        dto.setNbContribuables(contribuables.size());

        List<ZoneDashboardDto.QuartierPerformance> perfList = quartiers.stream().map(q -> {
            ZoneDashboardDto.QuartierPerformance perf = new ZoneDashboardDto.QuartierPerformance();
            perf.setQuartierId(q.getId());
            perf.setQuartierNom(q.getNom());
            List<Secteur> qSecteurs = secteurRepository.findByQuartierId(q.getId());
            perf.setNbAgents(0);
            perf.setNbContribuables(0);
            perf.setNbVisites(0);
            perf.setTauxCouverture(0);
            perf.setMontantCollecte(BigDecimal.ZERO);
            perf.setAnomalies((int) anomalieRepository.countOpenByQuartierId(q.getId()));
            return perf;
        }).collect(Collectors.toList());
        dto.setPerformanceQuartiers(perfList);

        dto.setAnomalies(perfList.stream().mapToInt(ZoneDashboardDto.QuartierPerformance::getAnomalies).sum());
        return ResponseEntity.ok(dto);
    }

    // ─── B. Comparaison des quartiers ──────────────────────────────

    @GetMapping("/quartiers/comparaison/{zoneId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Comparaison des performances des quartiers")
    public ResponseEntity<List<ZoneDashboardDto.QuartierPerformance>> comparerQuartiers(@PathVariable Long zoneId) {
        List<Quartier> quartiers = quartierRepository.findByZoneId(zoneId);
        List<ZoneDashboardDto.QuartierPerformance> result = quartiers.stream().map(q -> {
            ZoneDashboardDto.QuartierPerformance perf = new ZoneDashboardDto.QuartierPerformance();
            perf.setQuartierId(q.getId());
            perf.setQuartierNom(q.getNom());
            perf.setAnomalies((int) anomalieRepository.countOpenByQuartierId(q.getId()));
            return perf;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    // ─── C. Gestion des anomalies ─────────────────────────────────

    @GetMapping("/anomalies")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Toutes les anomalies de la zone")
    public ResponseEntity<List<AnomalieDto>> getAnomalies(@RequestParam(required = false) String statut) {
        if (statut != null) {
            return ResponseEntity.ok(anomalieService.findByStatut(statut));
        }
        return ResponseEntity.ok(Collections.emptyList());
    }

    @PostMapping("/anomalies/{id}/cloturer")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Clôturer une anomalie")
    public ResponseEntity<AnomalieDto> cloturerAnomalie(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long clotureePar = body.get("clotureePar") != null ? ((Number) body.get("clotureePar")).longValue() : 0L;
        String commentaire = (String) body.get("commentaire");
        AnomalieDto result = anomalieService.clôturer(id, clotureePar, commentaire);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.ANOMALIE_CLOTURE,
                "CLOTURE_ANOMALIE", "ANOMALIE", id,
                "Anomalie " + id + " clôturée" + (commentaire != null ? ": " + commentaire : ""),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/anomalies/{id}/escaler")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Escalader une anomalie à la hiérarchie")
    public ResponseEntity<AnomalieDto> escalerAnomalie(
            @PathVariable Long id, @RequestBody Map<String, String> body) {
        AnomalieDto result = anomalieService.escaler(id, body.get("commentaire"));
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.ANOMALIE_ESCALEE,
                "ESCALADE_ANOMALIE", "ANOMALIE", id,
                "Anomalie " + id + " escaladée" + (body.get("commentaire") != null ? ": " + body.get("commentaire") : ""),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok(result);
    }

    // ─── D. Validation des propositions d'affectation ─────────────

    @GetMapping("/propositions")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Propositions d'affectation en attente de validation")
    public ResponseEntity<List<PropositionAffectationDto>> getPropositions(
            @RequestParam(required = false) Long quartierId,
            @RequestParam(required = false) String statut) {
        if (quartierId != null && statut != null) {
            return ResponseEntity.ok(propositionService.findByQuartierIdAndStatut(quartierId, statut));
        } else if (statut != null) {
            return ResponseEntity.ok(propositionService.findByStatut(statut));
        } else if (quartierId != null) {
            return ResponseEntity.ok(propositionService.findByQuartierId(quartierId));
        }
        return ResponseEntity.ok(propositionService.findByStatut("EN_ATTENTE"));
    }

    @PostMapping("/propositions/{id}/valider")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Valider une proposition d'affectation")
    public ResponseEntity<PropositionAffectationDto> validerProposition(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long valideePar = body.get("valideePar") != null ? ((Number) body.get("valideePar")).longValue() : 0L;
        String commentaire = (String) body.get("commentaire");
        PropositionAffectationDto result = propositionService.valider(id, valideePar, commentaire);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.VALIDATION_PROPOSITION,
                "VALIDATION_PROPOSITION", "PROPOSITION", id,
                "Proposition " + id + " validée" + (commentaire != null ? ": " + commentaire : ""),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/propositions/{id}/rejeter")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Rejeter une proposition d'affectation")
    public ResponseEntity<PropositionAffectationDto> rejeterProposition(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long valideePar = body.get("valideePar") != null ? ((Number) body.get("valideePar")).longValue() : 0L;
        String commentaire = (String) body.get("commentaire");
        PropositionAffectationDto result = propositionService.rejeter(id, valideePar, commentaire);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.REJET_PROPOSITION,
                "REJET_PROPOSITION", "PROPOSITION", id,
                "Proposition " + id + " rejetée" + (commentaire != null ? ": " + commentaire : ""),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok(result);
    }

    // ─── E. Performance des agents ────────────────────────────────

    @GetMapping("/agents/performance/{zoneId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISEUR')")
    @Operation(summary = "Performance des agents de la zone")
    public ResponseEntity<List<Map<String, Object>>> getAgentPerformance(@PathVariable Long zoneId) {
        List<Agents> agents = agentRepository.findByZoneId(zoneId);
        List<Map<String, Object>> result = agents.stream().map(a -> {
            Map<String, Object> perf = new LinkedHashMap<>();
            perf.put("agentId", a.getId());
            perf.put("agentNom", a.getNom() + " " + a.getPrenom());
            perf.put("matricule", a.getMatricule());
            perf.put("statut", a.getStatut() != null ? a.getStatut().name() : "ACTIF");
            return perf;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }
}
