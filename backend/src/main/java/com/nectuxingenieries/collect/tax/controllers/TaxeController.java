package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.TaxeDto;
import com.nectuxingenieries.collect.tax.services.TaxeService;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/taxcollect/taxe")
@RequiredArgsConstructor
@Tag(name = "Taxes", description = "API de gestion des taxes")
public class TaxeController {

    @Autowired
    private TaxeService taxeService;


    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody TaxeDto taxeDto, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(bindingResult.getAllErrors());
        }
        
        try {
            TaxeDto created = taxeService.create(taxeDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            if (e.getMessage().contains("unique constraint") && e.getMessage().contains("nom")) {
                return ResponseEntity.badRequest().body("Une taxe avec ce nom existe déjà");
            }
            if (e.getMessage().contains("check constraint")) {
                return ResponseEntity.badRequest().body("Valeur non valide pour un champ");
            }
            return ResponseEntity.badRequest().body("Erreur de base de données: " + e.getMessage());
        }
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PutMapping("/{id}")
    public ResponseEntity<TaxeDto> update(@PathVariable Long id,
                                          @RequestBody TaxeDto taxeDto) {
        TaxeDto updated = taxeService.update(id, taxeDto);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/{id}")
    public ResponseEntity<TaxeDto> findById(@PathVariable Long id) {
        TaxeDto taxe = taxeService.findById(id)
                .orElseThrow(() -> new RuntimeException("Taxe non trouvée avec l'ID: " + id));
        return ResponseEntity.ok(taxe);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping
    public ResponseEntity<List<TaxeDto>> findAll() {
        List<TaxeDto> taxeList = taxeService.findAll();
        return ResponseEntity.ok(taxeList);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/all")
    public ResponseEntity<List<TaxeDto>> findAllAll() {
        List<TaxeDto> contribuableList = taxeService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/page")
    public ResponseEntity<Page<TaxeDto>> findAllPageable(@PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeDto> page = taxeService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/filter")
    public ResponseEntity<Page<TaxeDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeDto> page = taxeService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        taxeService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{id}/restore")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        taxeService.restore(id);
        return ResponseEntity.ok().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/including-deleted")
    public ResponseEntity<List<TaxeDto>> findAllIncludingDeleted() {
        return ResponseEntity.ok(taxeService.findAllIncludingDeleted());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/search")
    public ResponseEntity<Page<TaxeDto>> searchTaxes(@RequestParam String searchTerm,
                                                      @RequestParam(required = false) Map<String, String> filters,
                                                      @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeDto> searchResults = taxeService.searchTaxes(searchTerm, filters, pageable);
        return ResponseEntity.ok(searchResults);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/categories")
    public ResponseEntity<List<String>> getCategories() {
        List<String> categories = taxeService.getCategories();
        return ResponseEntity.ok(categories);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/periodicites")
    public ResponseEntity<List<String>> getPeriodicites() {
        List<String> periodicites = taxeService.getPeriodicites();
        return ResponseEntity.ok(periodicites);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/stats")
    @Hidden
    public ResponseEntity<Map<String, Object>> getTaxeStats() {
        Map<String, Object> stats = taxeService.getTaxeStats();
        return ResponseEntity.ok(stats);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/export")
    public ResponseEntity<byte[]> exportTaxes(@RequestParam(required = false) String format,
                                              @RequestParam(required = false) String categorie) {
        byte[] exportData = taxeService.exportTaxes(format, categorie);
        String filename = "taxes_" + new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + 
                         (format != null && format.equals("csv") ? ".csv" : ".xlsx");
        
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
                .header("Content-Type", format != null && format.equals("csv") ? "text/csv" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(exportData);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PostMapping("/{id}/duplicate")
    public ResponseEntity<TaxeDto> duplicateTaxe(@PathVariable Long id) {
        TaxeDto duplicated = taxeService.duplicateTaxe(id);
        return ResponseEntity.status(HttpStatus.CREATED).body(duplicated);
    }
}
