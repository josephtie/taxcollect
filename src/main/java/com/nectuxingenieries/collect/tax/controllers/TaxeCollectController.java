package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.services.TaxeCollectService;
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
@RequestMapping("api/taxcollect/collect")
@RequiredArgsConstructor
public class TaxeCollectController {

    @Autowired
    private  TaxeCollectService taxeCollecteService;



    @PostMapping
    public ResponseEntity<TaxeCollectDto> create(@RequestBody TaxeCollectDto taxeCollectDto) {
        TaxeCollectDto created = taxeCollecteService.create(taxeCollectDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaxeCollectDto> update(@PathVariable Long id,
                                                  @RequestBody TaxeCollectDto taxeCollectDto) {
        TaxeCollectDto updated = taxeCollecteService.update(id, taxeCollectDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaxeCollectDto> findById(@PathVariable Long id) {
        TaxeCollectDto contribuable = taxeCollecteService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<TaxeCollectDto>> findAll() {
        List<TaxeCollectDto> contribuableList = taxeCollecteService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<TaxeCollectDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeCollectDto> page = taxeCollecteService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<TaxeCollectDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<TaxeCollectDto> page = taxeCollecteService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
