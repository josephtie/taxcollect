package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.*;
import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.*;
import com.nectuxingenieries.collect.tax.services.AnomalieService;
import com.nectuxingenieries.collect.tax.services.AuditEntryService;
import com.nectuxingenieries.collect.tax.services.PropositionAffectationService;
import com.nectuxingenieries.collect.tax.security.TerritorialScopeContext;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("api/taxcollect/responsable")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER')")
@Tag(name = "Responsable Quartier", description = "API du Responsable de Quartier / Chef d'Équipe")
public class ResponsableController {

    private final QuartierRepository quartierRepository;
    private final SecteurRepository secteurRepository;
    private final AgentRepository agentRepository;
    private final ContribuableRepository contribuableRepository;
    private final TransactionRepository transactionRepository;
    private final VisiteRepository visiteRepository;
    private final AnomalieRepository anomalieRepository;
    private final AnomalieService anomalieService;
    private final PropositionAffectationService propositionService;
    private final AuditEntryService auditEntryService;
    private final TerritorialScopeContext scopeContext;

    public ResponsableController(QuartierRepository quartierRepository, SecteurRepository secteurRepository,
                                  AgentRepository agentRepository, ContribuableRepository contribuableRepository,
                                  TransactionRepository transactionRepository, VisiteRepository visiteRepository,
                                  AnomalieRepository anomalieRepository, AnomalieService anomalieService,
                                  PropositionAffectationService propositionService,
                                  AuditEntryService auditEntryService,
                                  TerritorialScopeContext scopeContext) {
        this.quartierRepository = quartierRepository;
        this.secteurRepository = secteurRepository;
        this.agentRepository = agentRepository;
        this.contribuableRepository = contribuableRepository;
        this.transactionRepository = transactionRepository;
        this.visiteRepository = visiteRepository;
        this.anomalieRepository = anomalieRepository;
        this.anomalieService = anomalieService;
        this.propositionService = propositionService;
        this.auditEntryService = auditEntryService;
        this.scopeContext = scopeContext;
    }

    // ─── A. Tableau de bord du quartier ────────────────────────────

    @GetMapping("/dashboard")
    @Operation(summary = "Tableau de bord du quartier du responsable")
    public ResponseEntity<ResponsableDashboardDto> getDashboard(@RequestParam Long quartierId) {
        Quartier quartier = quartierRepository.findById(quartierId).orElse(null);
        List<Secteur> secteurs = secteurRepository.findByQuartierId(quartierId);

        ResponsableDashboardDto dto = new ResponsableDashboardDto();
        ResponsableDashboardDto.QuartierInfo qi = new ResponsableDashboardDto.QuartierInfo();
        qi.setId(quartierId);
        qi.setNom(quartier != null ? quartier.getNom() : "Quartier " + quartierId);
        dto.setQuartier(qi);

        ResponsableDashboardDto.SecteursInfo si = new ResponsableDashboardDto.SecteursInfo();
        si.setTotal(secteurs.size());
        si.setListe(secteurs.stream().map(Secteur::getNom).collect(Collectors.toList()));
        dto.setSecteurs(si);

        List<Agents> agents = agentRepository.findActiveAgents();
        ResponsableDashboardDto.AgentsInfo ai = new ResponsableDashboardDto.AgentsInfo();
        ai.setTotal(agents.size());
        ai.setActifs(agents.size());
        ai.setAbsents(0);
        dto.setAgents(ai);

        List<Contribuable> contribuables = contribuableRepository.findActiveContribuables();
        ResponsableDashboardDto.ContribuablesInfo ci = new ResponsableDashboardDto.ContribuablesInfo();
        ci.setTotal(contribuables.size());
        ci.setVisites(0);
        ci.setNonVisites(contribuables.size());
        ci.setNouveaux(0);
        ci.setImpayes(0);
        dto.setContribuables(ci);

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDateTime.now();
        List<Transaction> todayTransactions = transactionRepository
                .findTransactionsByAgentAndDateRange(0L, todayStart, todayEnd);
        ResponsableDashboardDto.CollecteInfo coli = new ResponsableDashboardDto.CollecteInfo();
        coli.setMontantCollecte(BigDecimal.ZERO);
        coli.setImpayes(BigDecimal.ZERO);
        coli.setPaiementsJour(0);
        dto.setCollecte(coli);

        dto.setAnomalies((int) anomalieRepository.countOpenByQuartierId(quartierId));
        dto.setProgression(contribuables.isEmpty() ? 0 : (double) 0 / contribuables.size() * 100);

        return ResponseEntity.ok(dto);
    }

    // ─── B. Organisation des agents ────────────────────────────────

    @GetMapping("/agents")
    @Operation(summary = "Liste des agents du quartier")
    public ResponseEntity<List<Map<String, Object>>> getAgents(@RequestParam Long quartierId) {
        List<Secteur> secteurs = secteurRepository.findByQuartierId(quartierId);
        List<Agents> agents = agentRepository.findActiveAgents();

        List<Map<String, Object>> result = agents.stream().map(a -> {
            Map<String, Object> agentMap = new LinkedHashMap<>();
            agentMap.put("id", a.getId());
            agentMap.put("nom", a.getNom());
            agentMap.put("prenom", a.getPrenom());
            agentMap.put("matricule", a.getMatricule());
            agentMap.put("statut", a.getStatut() != null ? a.getStatut().name() : "ACTIF");
            agentMap.put("secteur", secteurs.isEmpty() ? null : secteurs.get(0).getNom());
            LocalDateTime todayStart = LocalDate.now().atStartOfDay();
            List<Transaction> todayTx = transactionRepository
                    .findTransactionsByAgentAndDateRange(a.getId(), todayStart, LocalDateTime.now());
            agentMap.put("visitesJour", todayTx.size());
            agentMap.put("paiementsJour", todayTx.size());
            agentMap.put("collecteJour", todayTx.stream()
                    .map(Transaction::getMontant)
                    .reduce(BigDecimal.ZERO, BigDecimal::add));
            return agentMap;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    @PostMapping("/agents/proposer-affectation")
    @Operation(summary = "Proposer une affectation d'agent (validation superviseur)")
    public ResponseEntity<PropositionAffectationDto> proposerAffectation(@RequestBody Map<String, Object> body) {
        PropositionAffectationDto dto = new PropositionAffectationDto();
        dto.setAgentId(((Number) body.get("agentId")).longValue());
        Object secteurId = body.get("secteurId");
        if (secteurId != null) dto.setSecteurId(((Number) secteurId).longValue());
        dto.setMotif((String) body.get("motif"));
        Object quartierId = body.get("quartierId");
        if (quartierId != null) dto.setQuartierId(((Number) quartierId).longValue());
        dto.setProposeParRole("RESPONSABLE_QUARTIER");
        PropositionAffectationDto result = propositionService.create(dto);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.PROPOSITION_AFFECTATION,
                "PROPOSITION_AFFECTATION", "AGENT", dto.getAgentId(),
                "Proposition d'affectation pour agent " + dto.getAgentId(),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, dto.getQuartierId());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/agents/propositions")
    @Operation(summary = "Propositions d'affectation en attente")
    public ResponseEntity<List<PropositionAffectationDto>> getPropositions(@RequestParam Long quartierId) {
        return ResponseEntity.ok(propositionService.findByQuartierId(quartierId));
    }

    @PostMapping("/agents/absence")
    @Operation(summary = "Signaler une absence d'agent")
    public ResponseEntity<Void> signalerAbsence(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok().build();
    }

    // ─── C. Suivi des contribuables ────────────────────────────────

    @GetMapping("/contribuables")
    @Operation(summary = "Contribuables du quartier")
    public ResponseEntity<List<Map<String, Object>>> getContribuables(
            @RequestParam Long quartierId,
            @RequestParam(required = false) Map<String, Object> filters) {
        List<Contribuable> contribuables = contribuableRepository.findActiveContribuables();
        List<Map<String, Object>> result = contribuables.stream().map(c -> {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", c.getId());
            map.put("nom", c.getNom());
            map.put("prenom", c.getPrenom());
            map.put("telephone", c.getTelephone());
            map.put("activite", c.getActivite());
            map.put("adresse", c.getAdresse());
            map.put("statut", "A_JOUR");
            return map;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/contribuables/erreur-affectation")
    @Operation(summary = "Signaler une erreur d'affectation d'un contribuable")
    public ResponseEntity<Void> signalerErreurAffectation(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok().build();
    }

    // ─── D. Suivi des visites terrain ──────────────────────────────

    @GetMapping("/visites")
    @Operation(summary = "Visites terrain du quartier")
    public ResponseEntity<List<Map<String, Object>>> getVisites(
            @RequestParam Long quartierId,
            @RequestParam(required = false) Map<String, Object> filters) {
        return ResponseEntity.ok(Collections.emptyList());
    }

    @GetMapping("/secteurs/couverture")
    @Operation(summary = "Couverture par secteur")
    public ResponseEntity<List<Map<String, Object>>> getSecteursCouverture(@RequestParam Long quartierId) {
        List<Secteur> secteurs = secteurRepository.findByQuartierId(quartierId);
        List<Map<String, Object>> result = secteurs.stream().map(s -> {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("secteur", s.getNom());
            map.put("tauxCouverture", 0);
            map.put("contribuables", 0);
            map.put("visites", 0);
            map.put("statut", "OK");
            return map;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    // ─── E. Contrôle des collectes ────────────────────────────────

    @GetMapping("/collectes")
    @Operation(summary = "Collectes du quartier")
    public ResponseEntity<List<Map<String, Object>>> getCollectes(
            @RequestParam Long quartierId,
            @RequestParam(required = false) Map<String, Object> filters) {
        return ResponseEntity.ok(Collections.emptyList());
    }

    @PostMapping("/collectes/signaler-douteuse")
    @Operation(summary = "Signaler une opération douteuse")
    public ResponseEntity<Void> signalerOperationDouteuse(@RequestBody Map<String, Object> body) {
        Long transactionId = ((Number) body.get("transactionId")).longValue();
        String motif = (String) body.get("motif");
        AnomalieDto anomalie = new AnomalieDto();
        anomalie.setTypeAnomalie(com.nectuxingenieries.collect.tax.models.enums.TypeAnomalie.OPERATION_DOUTEUSE);
        anomalie.setProbleme(motif);
        anomalie.setCreeParRole("RESPONSABLE_QUARTIER");
        AnomalieDto result = anomalieService.create(anomalie);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.OPERATION_DOUTEUSE,
                "SIGNALEMENT_OPERATION_DOUTEUSE", "TRANSACTION", transactionId,
                "Opération douteuse signalée: " + motif,
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok().build();
    }

    // ─── F. Gestion des anomalies ─────────────────────────────────

    @GetMapping("/anomalies")
    @Operation(summary = "Anomalies du quartier")
    public ResponseEntity<List<AnomalieDto>> getAnomalies(
            @RequestParam Long quartierId,
            @RequestParam(required = false) String statut) {
        if (statut != null) {
            return ResponseEntity.ok(anomalieService.findByQuartierIdAndStatut(quartierId, statut));
        }
        return ResponseEntity.ok(anomalieService.findByQuartierId(quartierId));
    }

    @PostMapping("/anomalies")
    @Operation(summary = "Créer une anomalie")
    public ResponseEntity<AnomalieDto> creerAnomalie(@RequestBody AnomalieDto anomalie) {
        if (anomalie.getCreeParRole() == null) {
            anomalie.setCreeParRole("RESPONSABLE_QUARTIER");
        }
        AnomalieDto result = anomalieService.create(anomalie);
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.ANOMALIE_CREE,
                "CREATION_ANOMALIE", "ANOMALIE", result.getId(),
                "Anomalie créée: " + anomalie.getProbleme(),
                scopeContext.getUserId(), scopeContext.getUserRole(), null, anomalie.getQuartierId());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/anomalies/{id}/documenter")
    @Operation(summary = "Documenter une anomalie")
    public ResponseEntity<AnomalieDto> documenterAnomalie(
            @PathVariable Long id, @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(anomalieService.documenter(id, body.get("commentaire")));
    }

    @PostMapping("/anomalies/{id}/transmettre")
    @Operation(summary = "Transmettre l'anomalie au superviseur")
    public ResponseEntity<AnomalieDto> transmettreAnomalie(
            @PathVariable Long id, @RequestBody Map<String, String> body) {
        AnomalieDto result = anomalieService.transmettre(id, body.get("commentaire"));
        auditEntryService.trace(com.nectuxingenieries.collect.tax.models.enums.TypeAudit.ANOMALIE_TRANSMISE,
                "TRANSMISSION_ANOMALIE", "ANOMALIE", id,
                "Anomalie " + id + " transmise au superviseur",
                scopeContext.getUserId(), scopeContext.getUserRole(), null, null);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/anomalies/{id}/affecter")
    @Operation(summary = "Affecter une action sur une anomalie")
    public ResponseEntity<AnomalieDto> affecterAction(
            @PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long agentId = ((Number) body.get("agentId")).longValue();
        String action = (String) body.get("action");
        return ResponseEntity.ok(anomalieService.affecterAction(id, agentId, action));
    }

    // ─── G. Rapports du quartier ──────────────────────────────────

    @GetMapping("/rapports")
    @Operation(summary = "Rapport du quartier")
    public ResponseEntity<Map<String, Object>> getRapport(
            @RequestParam Long quartierId,
            @RequestParam(required = false) Map<String, Object> filters) {
        Map<String, Object> rapport = new LinkedHashMap<>();
        rapport.put("quartier", quartierRepository.findById(quartierId)
                .map(Quartier::getNom).orElse("Quartier " + quartierId));
        rapport.put("synthese", Map.of(
                "contribuablesTotal", 0,
                "contribuablesVisites", 0,
                "tauxCouverture", 0,
                "montantCollecte", 0,
                "impayes", 0,
                "nbPaiements", 0,
                "nbAnomalies", anomalieRepository.countOpenByQuartierId(quartierId)
        ));
        return ResponseEntity.ok(rapport);
    }
}
