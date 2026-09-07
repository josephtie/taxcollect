package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.services.AssessmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assessments")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Assessments", description = "API de génération et gestion des avis d'imposition")
public class AssessmentController {

    @Autowired
    private AssessmentService assessmentService;

    @PostMapping("/generate/{taxeId}")
    @Operation(summary = "Générer les avis pour une taxe spécifique", description = "Génère les avis d'imposition pour une taxe donnée sur la période contenant la date cible")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Avis générés avec succès"),
            @ApiResponse(responseCode = "404", description = "Taxe non trouvée")
    })
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    public ResponseEntity<Map<String, Object>> generateForTaxe(
            @PathVariable Long taxeId,
            @Parameter(description = "Date cible pour déterminer la période (défaut: aujourd'hui)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate targetDate) {

        if (targetDate == null) {
            targetDate = LocalDate.now();
        }

        int generated = assessmentService.generateForPeriod(taxeId, targetDate);

        Map<String, Object> response = new HashMap<>();
        response.put("taxeId", taxeId);
        response.put("targetDate", targetDate);
        response.put("generated", generated);
        response.put("message", generated + " avis générés avec succès");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/generate-all")
    @Operation(summary = "Générer les avis pour toutes les taxes actives", description = "Lance la génération d'avis pour toutes les taxes actives sur la période courante")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    public ResponseEntity<Map<String, Object>> generateForAll(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate targetDate) {

        if (targetDate == null) {
            targetDate = LocalDate.now();
        }

        int generated = assessmentService.generateForAllActiveTaxes(targetDate);

        Map<String, Object> response = new HashMap<>();
        response.put("targetDate", targetDate);
        response.put("generated", generated);
        response.put("message", generated + " avis générés au total");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/mark-overdue")
    @Operation(summary = "Marquer les avis en retard", description = "Met à jour le statut des avis dont la date d'échéance est dépassée")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR')")
    public ResponseEntity<Map<String, Object>> markOverdue() {
        int overdue = assessmentService.markOverdueAssessments();

        Map<String, Object> response = new HashMap<>();
        response.put("overdue", overdue);
        response.put("message", overdue + " avis marqués en retard");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/period")
    @Operation(summary = "Rechercher les avis par période", description = "Retourne tous les avis d'imposition dans une période donnée")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR')")
    public ResponseEntity<List<TaxeCollectDto>> findByPeriod(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodStart,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodEnd) {

        List<TaxeCollectDto> assessments = assessmentService.findAssessmentsByPeriod(periodStart, periodEnd);
        return ResponseEntity.ok(assessments);
    }

    @GetMapping("/export")
    @Operation(summary = "Exporter les avis d'imposition", description = "Exporte les avis au format CSV ou Excel pour une période donnée")
    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR')")
    public ResponseEntity<byte[]> exportAssessments(
            @Parameter(description = "Format d'export (csv ou xlsx)") @RequestParam(required = false, defaultValue = "csv") String format,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodStart,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodEnd) {

        byte[] exportData = assessmentService.exportAssessments(format, periodStart, periodEnd);
        String filename = "avis_imposition_" + new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + "." + format;

        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
                .header("Content-Type", format.equals("csv") ? "text/csv" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(exportData);
    }
}
