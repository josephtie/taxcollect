package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.CommuneDto;
import com.nectuxingenieries.collect.tax.services.CommuneService;
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
@RequestMapping("api/taxcollect/commune")
@RequiredArgsConstructor
public class CommuneController {

    @Autowired
   private  CommuneService communeService;



    @PostMapping
    public ResponseEntity<CommuneDto> create(@RequestBody CommuneDto CommuneDto) {
        CommuneDto created = communeService.create(CommuneDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CommuneDto> update(@PathVariable Long id,
                                                  @RequestBody CommuneDto CommuneDto) {
        CommuneDto updated = communeService.update(id, CommuneDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CommuneDto> findById(@PathVariable Long id) {
        CommuneDto contribuable = communeService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<CommuneDto>> findAll() {
        List<CommuneDto> contribuableList = communeService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<CommuneDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<CommuneDto> page = communeService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<CommuneDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<CommuneDto> page = communeService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
