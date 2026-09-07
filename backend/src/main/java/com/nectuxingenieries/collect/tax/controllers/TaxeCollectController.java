package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.services.TaxeCollectService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/taxcollect/collect")
@RequiredArgsConstructor
@Tag(name = "Collecte", description = "API de gestion des collectes de taxes")
public class TaxeCollectController {

    @Autowired
    private  TaxeCollectService taxeCollecteService;



    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    @PostMapping
    public ResponseEntity<TaxeCollectDto> create(@RequestBody TaxeCollectDto taxeCollectDto) {
        TaxeCollectDto created = taxeCollecteService.create(taxeCollectDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR')")
    @PutMapping("/{id}")
    public ResponseEntity<TaxeCollectDto> update(@PathVariable Long id,
                                                  @RequestBody TaxeCollectDto taxeCollectDto) {
        TaxeCollectDto updated = taxeCollecteService.update(id, taxeCollectDto);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR', 'AGENT')")
    @GetMapping("/{id}")
    public ResponseEntity<TaxeCollectDto> findById(@PathVariable Long id) {
        TaxeCollectDto contribuable = taxeCollecteService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR', 'AGENT')")
    @GetMapping("/all")
    public ResponseEntity<List<TaxeCollectDto>> findAll() {
        List<TaxeCollectDto> contribuableList = taxeCollecteService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR', 'AGENT')")
    @GetMapping("/page")
    public ResponseEntity<Page<TaxeCollectDto>> findAllPageable(@PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeCollectDto> page = taxeCollecteService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'TRESOR', 'SUPERVISEUR', 'AGENT')")
    @GetMapping("/filter")
    public ResponseEntity<Page<TaxeCollectDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeCollectDto> page = taxeCollecteService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
