package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.ClotureCaisseDTO;
import com.nectuxingenieries.collect.tax.dto.PageResponse;
import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import com.nectuxingenieries.collect.tax.services.ClotureCaisseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/cloture-caisse")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Clôture de Caisse", description = "API de gestion des clôtures de caisse journalières")
public class ClotureCaisseController {

    @Autowired
    private ClotureCaisseService clotureCaisseService;

    // Récupérer toutes les clôtures (paginé)
    @GetMapping
    @Operation(summary = "Lister toutes les clôtures (paginé)", description = "Retourne toutes les clôtures de caisse avec pagination")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<PageResponse<ClotureCaisseDTO>> getAllClotures(
            @Parameter(description = "Numéro de page (0-based)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Taille de la page") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "Tri") @RequestParam(defaultValue = "dateCloture,desc") String sort) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<ClotureCaisseDTO> cloturePage = clotureCaisseService.getAllClotures(pageable);
        
        PageResponse<ClotureCaisseDTO> response = new PageResponse<>(
            cloturePage.getContent(),
            cloturePage.getNumber(),
            cloturePage.getSize(),
            cloturePage.getTotalElements(),
            cloturePage.getTotalPages()
        );
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/initier")
    @Operation(summary = "Initier une clôture de caisse", description = "Crée une nouvelle clôture de caisse pour un agent à une date donnée")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Clôture de caisse initiée avec succès"),
        @ApiResponse(responseCode = "400", description = "Une clôture existe déjà pour cet agent à cette date"),
        @ApiResponse(responseCode = "404", description = "Agent non trouvé")
    })
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<ClotureCaisseDTO> initierClotureCaisse(
            @Parameter(description = "ID de l'agent") @RequestParam Long agentId,
            @Parameter(description = "Date de clôture") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateCloture) {
        try {
            ClotureCaisseDTO cloture = clotureCaisseService.initierClotureCaisse(agentId, dateCloture);
            return ResponseEntity.status(201).body(cloture);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{clotureId}/soumettre")
    @Operation(summary = "Soumettre une clôture de caisse", description = "Soumet la déclaration du montant en main par l'agent")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Clôture soumise avec succès"),
        @ApiResponse(responseCode = "400", description = "La clôture ne peut plus être modifiée"),
        @ApiResponse(responseCode = "404", description = "Clôture non trouvée")
    })
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<ClotureCaisseDTO> soumettreClotureCaisse(
            @Parameter(description = "ID de la clôture") @PathVariable Long clotureId,
            @Parameter(description = "Montant déclaré par l'agent") @RequestParam BigDecimal montantDeclare,
            @Parameter(description = "Commentaire de l'agent") @RequestParam(required = false) String commentaireAgent) {
        try {
            ClotureCaisseDTO cloture = clotureCaisseService.soumettreClotureCaisse(clotureId, montantDeclare, commentaireAgent);
            return ResponseEntity.ok().body(cloture);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{clotureId}/valider")
    @Operation(summary = "Valider une clôture de caisse", description = "Valide la clôture par le Trésor Public")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Clôture validée avec succès"),
        @ApiResponse(responseCode = "400", description = "La clôture n'est pas soumise"),
        @ApiResponse(responseCode = "404", description = "Clôture ou agent validateur non trouvé")
    })
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<ClotureCaisseDTO> validerClotureCaisse(
            @Parameter(description = "ID de la clôture") @PathVariable Long clotureId,
            @Parameter(description = "ID de l'agent qui valide") @RequestParam Long valideParId,
            @Parameter(description = "Commentaire du Trésor") @RequestParam(required = false) String commentaireTresor) {
        try {
            ClotureCaisseDTO cloture = clotureCaisseService.validerClotureCaisse(clotureId, valideParId, commentaireTresor);
            return ResponseEntity.ok().body(cloture);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{clotureId}/rejeter")
    @Operation(summary = "Rejeter une clôture de caisse", description = "Rejette la clôture par le Trésor Public")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Clôture rejetée avec succès"),
        @ApiResponse(responseCode = "400", description = "La clôture n'est pas soumise"),
        @ApiResponse(responseCode = "404", description = "Clôture ou agent validateur non trouvé")
    })
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<ClotureCaisseDTO> rejeterClotureCaisse(
            @Parameter(description = "ID de la clôture") @PathVariable Long clotureId,
            @Parameter(description = "ID de l'agent qui rejette") @RequestParam Long valideParId,
            @Parameter(description = "Motif du rejet") @RequestParam String commentaireTresor) {
        try {
            ClotureCaisseDTO cloture = clotureCaisseService.rejeterClotureCaisse(clotureId, valideParId, commentaireTresor);
            return ResponseEntity.ok().body(cloture);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{clotureId}/confirmer-depot")
    @Operation(summary = "Confirmer le dépôt bancaire", description = "Confirme le dépôt bancaire après validation de la clôture")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Dépot confirmé avec succès"),
        @ApiResponse(responseCode = "400", description = "La clôture n'est pas validée"),
        @ApiResponse(responseCode = "404", description = "Clôture non trouvée")
    })
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<ClotureCaisseDTO> confirmerDepotBanque(
            @Parameter(description = "ID de la clôture") @PathVariable Long clotureId,
            @Parameter(description = "Montant déposé en banque") @RequestParam BigDecimal montantDepose,
            @Parameter(description = "Référence du dépôt bancaire") @RequestParam String referenceDepot) {
        try {
            ClotureCaisseDTO cloture = clotureCaisseService.confirmerDepotBanque(clotureId, montantDepose, referenceDepot);
            return ResponseEntity.ok().body(cloture);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer une clôture de caisse", description = "Retourne les détails d'une clôture de caisse spécifique")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Clôture trouvée"),
        @ApiResponse(responseCode = "404", description = "Clôture non trouvée")
    })
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<ClotureCaisseDTO> getClotureCaisseById(
            @Parameter(description = "ID de la clôture") @PathVariable Long id) {
        Optional<ClotureCaisseDTO> cloture = clotureCaisseService.getClotureCaisseById(id);
        return cloture.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent-date")
    @Operation(summary = "Récupérer une clôture par agent et date", description = "Retourne la clôture de caisse pour un agent à une date spécifique")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Clôture trouvée"),
        @ApiResponse(responseCode = "404", description = "Clôture non trouvée")
    })
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<ClotureCaisseDTO> getClotureCaisseByAgentAndDate(
            @Parameter(description = "ID de l'agent") @RequestParam Long agentId,
            @Parameter(description = "Date de clôture") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Optional<ClotureCaisseDTO> cloture = clotureCaisseService.getClotureCaisseByAgentAndDate(agentId, date);
        return cloture.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @Operation(summary = "Lister les clôtures d'un agent", description = "Retourne l'historique des clôtures de caisse d'un agent")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<ClotureCaisseDTO>> getClotureCaisseByAgent(
            @Parameter(description = "ID de l'agent") @PathVariable Long agentId) {
        List<ClotureCaisseDTO> clotures = clotureCaisseService.getClotureCaisseByAgent(agentId);
        return ResponseEntity.ok().body(clotures);
    }

    @GetMapping("/statut/{statut}")
    @Operation(summary = "Lister les clôtures par statut", description = "Retourne les clôtures ayant un statut spécifique")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<ClotureCaisseDTO>> getClotureCaisseByStatut(
            @Parameter(description = "Statut des clôtures") @PathVariable StatutCloture statut) {
        List<ClotureCaisseDTO> clotures = clotureCaisseService.getClotureCaisseByStatut(statut);
        return ResponseEntity.ok().body(clotures);
    }

    @GetMapping("/range")
    @Operation(summary = "Lister les clôtures par période", description = "Retourne les clôtures dans une période donnée")
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<List<ClotureCaisseDTO>> getClotureCaisseByDateRange(
            @Parameter(description = "Date de début") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate debut,
            @Parameter(description = "Date de fin") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {
        List<ClotureCaisseDTO> clotures = clotureCaisseService.getClotureCaisseByDateRange(debut, fin);
        return ResponseEntity.ok().body(clotures);
    }
}
