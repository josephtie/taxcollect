package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.TransactionDTO;
import com.nectuxingenieries.collect.tax.dto.PageResponse;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.services.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Transactions", description = "API de gestion des transactions de collecte de taxes")
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    @GetMapping
    @Operation(summary = "Lister toutes les transactions (paginé)", description = "Retourne toutes les transactions avec pagination")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Transactions trouvées"),
        @ApiResponse(responseCode = "403", description = "Accès non autorisé")
    })
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<PageResponse<TransactionDTO>> getAllTransactions(
            @Parameter(description = "Numéro de page (0-based)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Taille de la page") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "Tri") @RequestParam(defaultValue = "dateCreation,desc") String sort) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<TransactionDTO> transactionPage = transactionService.getAllTransactions(pageable);
        
        PageResponse<TransactionDTO> response = new PageResponse<>(
            transactionPage.getContent(),
            transactionPage.getNumber(),
            transactionPage.getSize(),
            transactionPage.getTotalElements(),
            transactionPage.getTotalPages()
        );
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    @Operation(summary = "Créer une nouvelle transaction", description = "Crée une nouvelle transaction de collecte de taxe avec génération automatique du numéro de reçu et du hash de sécurité")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Transaction créée avec succès"),
        @ApiResponse(responseCode = "400", description = "Données invalides"),
        @ApiResponse(responseCode = "404", description = "Agent, contribuable ou zone non trouvé")
    })
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<TransactionDTO> createTransaction(@Valid @RequestBody TransactionDTO transactionDTO) {
        TransactionDTO createdTransaction = transactionService.createTransaction(transactionDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdTransaction);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer une transaction par ID", description = "Retourne les détails d'une transaction spécifique")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Transaction trouvée"),
        @ApiResponse(responseCode = "404", description = "Transaction non trouvée")
    })
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<TransactionDTO> getTransactionById(
            @Parameter(description = "ID de la transaction") @PathVariable Long id) {
        return transactionService.getTransactionById(id)
                .map(transaction -> ResponseEntity.ok().body(transaction))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/receipt/{numeroRecu}")
    @Operation(summary = "Récupérer une transaction par numéro de reçu", description = "Retourne les détails d'une transaction via son numéro de reçu unique")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Transaction trouvée"),
        @ApiResponse(responseCode = "404", description = "Transaction non trouvée")
    })
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<TransactionDTO> getTransactionByNumeroRecu(
            @Parameter(description = "Numéro de reçu de la transaction") @PathVariable String numeroRecu) {
        return transactionService.getTransactionByNumeroRecu(numeroRecu)
                .map(transaction -> ResponseEntity.ok().body(transaction))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @Operation(summary = "Lister les transactions d'un agent", description = "Retourne la liste de toutes les transactions effectuées par un agent spécifique")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByAgent(
            @Parameter(description = "ID de l'agent") @PathVariable Long agentId) {
        List<TransactionDTO> transactions = transactionService.getTransactionsByAgent(agentId);
        return ResponseEntity.ok().body(transactions);
    }

    @GetMapping("/agent/{agentId}/range")
    @Operation(summary = "Lister les transactions d'un agent par période", description = "Retourne les transactions d'un agent dans une période donnée")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByAgentAndDateRange(
            @Parameter(description = "ID de l'agent") @PathVariable Long agentId,
            @Parameter(description = "Date de début") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @Parameter(description = "Date de fin") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        List<TransactionDTO> transactions = transactionService.getTransactionsByAgentAndDateRange(agentId, debut, fin);
        return ResponseEntity.ok().body(transactions);
    }

    @PutMapping("/{id}/sync")
    @Operation(summary = "Synchroniser une transaction hors-ligne", description = "Marque une transaction hors-ligne comme synchronisée")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Transaction synchronisée avec succès"),
        @ApiResponse(responseCode = "404", description = "Transaction non trouvée"),
        @ApiResponse(responseCode = "400", description = "La transaction n'est pas en mode hors-ligne")
    })
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<TransactionDTO> synchronizeTransaction(
            @Parameter(description = "ID de la transaction à synchroniser") @PathVariable Long id) {
        try {
            TransactionDTO transaction = transactionService.synchronizeTransaction(id);
            return ResponseEntity.ok().body(transaction);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/sync-all")
    @Operation(summary = "Synchroniser toutes les transactions hors-ligne", description = "Synchronise toutes les transactions en attente de synchronisation")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<List<TransactionDTO>> synchronizeAllOfflineTransactions() {
        List<TransactionDTO> transactions = transactionService.synchronizeOfflineTransactions();
        return ResponseEntity.ok().body(transactions);
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "Mettre à jour le statut d'une transaction", description = "Permet de changer le statut d'une transaction")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Statut mis à jour avec succès"),
        @ApiResponse(responseCode = "404", description = "Transaction non trouvée")
    })
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<TransactionDTO> updateTransactionStatus(
            @Parameter(description = "ID de la transaction") @PathVariable Long id,
            @Parameter(description = "Nouveau statut") @RequestParam StatutTransaction status) {
        TransactionDTO transaction = transactionService.updateTransactionStatus(id, status);
        return ResponseEntity.ok().body(transaction);
    }

    @GetMapping("/{id}/verify")
    @Operation(summary = "Vérifier l'intégrité d'une transaction", description = "Vérifie que le hash de la transaction est valide")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Résultat de la vérification"),
        @ApiResponse(responseCode = "404", description = "Transaction non trouvée")
    })
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<Boolean> verifyTransactionHash(
            @Parameter(description = "ID de la transaction") @PathVariable Long id,
            @Parameter(description = "Hash à vérifier") @RequestParam String hash) {
        boolean isValid = transactionService.verifyTransactionHash(id, hash);
        return ResponseEntity.ok().body(isValid);
    }

    @GetMapping("/offline/count")
    @Operation(summary = "Compter les transactions hors-ligne", description = "Retourne le nombre de transactions en attente de synchronisation")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<Long> countOfflineTransactions() {
        Long count = transactionService.countOfflineTransactions();
        return ResponseEntity.ok().body(count);
    }

    @GetMapping("/filter")
    @Operation(summary = "Filtrer les transactions", description = "Retourne les transactions filtrées par date, agent, mode de paiement, etc.")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<Page<TransactionDTO>> filterTransactions(
            @Parameter(description = "Date de début") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @Parameter(description = "Date de fin") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin,
            @Parameter(description = "ID de l'agent") @RequestParam(required = false) Long agentId,
            @Parameter(description = "Mode de paiement") @RequestParam(required = false) String paymentMethod,
            @Parameter(description = "Statut de la transaction") @RequestParam(required = false) StatutTransaction statut,
            @Parameter(description = "Pagination") @RequestParam(required = false) Integer page,
            @Parameter(description = "Taille de la page") @RequestParam(required = false) Integer size) {
        
        Page<TransactionDTO> transactions = transactionService.filterTransactions(debut, fin, agentId, paymentMethod, statut, page, size);
        return ResponseEntity.ok().body(transactions);
    }

    @GetMapping("/stats")
    @Operation(summary = "Statistiques des transactions", description = "Retourne les statistiques globales des transactions")
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getTransactionStats(
            @Parameter(description = "Date de début") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @Parameter(description = "Date de fin") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        
        Map<String, Object> stats = transactionService.getTransactionStats(debut, fin);
        return ResponseEntity.ok().body(stats);
    }

    @GetMapping("/export")
    @Operation(summary = "Exporter les transactions", description = "Exporte les transactions au format CSV ou Excel")
    @PreAuthorize("hasAnyRole('TRESOR', 'ADMIN')")
    public ResponseEntity<byte[]> exportTransactions(
            @Parameter(description = "Format d'export") @RequestParam(required = false, defaultValue = "csv") String format,
            @Parameter(description = "Date de début") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @Parameter(description = "Date de fin") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin,
            @Parameter(description = "ID de l'agent") @RequestParam(required = false) Long agentId,
            @Parameter(description = "Mode de paiement") @RequestParam(required = false) String paymentMethod) {
        
        byte[] exportData = transactionService.exportTransactions(format, debut, fin, agentId, paymentMethod);
        String filename = "transactions_" + new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + "." + format;
        
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
                .header("Content-Type", format.equals("csv") ? "text/csv" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(exportData);
    }

    @GetMapping("/zone/{zoneId}")
    @Operation(summary = "Transactions par zone", description = "Retourne les transactions pour une zone spécifique")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByZone(@PathVariable Long zoneId) {
        List<TransactionDTO> transactions = transactionService.getTransactionsByZone(zoneId);
        return ResponseEntity.ok().body(transactions);
    }

    @GetMapping("/contribuable/{contribuableId}")
    @Operation(summary = "Transactions par contribuable", description = "Retourne les transactions pour un contribuable spécifique")
    @PreAuthorize("hasAnyRole('AGENT', 'TRESOR', 'ADMIN')")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByContribuable(@PathVariable Long contribuableId) {
        List<TransactionDTO> transactions = transactionService.getTransactionsByContribuable(contribuableId);
        return ResponseEntity.ok().body(transactions);
    }
}
