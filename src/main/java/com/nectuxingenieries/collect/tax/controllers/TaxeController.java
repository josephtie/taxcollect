package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.TaxeDto;
import com.nectuxingenieries.collect.tax.services.TaxeService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/taxcollect/taxe")
@RequiredArgsConstructor
public class TaxeController {

    @Autowired
   private  TaxeService taxeService;



    @PostMapping
    public ResponseEntity<TaxeDto> create(@RequestBody TaxeDto taxeDto) {
        TaxeDto created = taxeService.create(taxeDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaxeDto> update(@PathVariable Long id,
                                                  @RequestBody TaxeDto taxeDto) {
        TaxeDto updated = taxeService.update(id, taxeDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaxeDto> findById(@PathVariable Long id) {
        TaxeDto contribuable = taxeService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<TaxeDto>> findAll() {
        List<TaxeDto> contribuableList = taxeService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<TaxeDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeDto> page = taxeService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<TaxeDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeDto> page = taxeService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
