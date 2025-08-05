package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.ContribuableDto;
import com.nectuxingenieries.collect.tax.services.ContribuableService;
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
@RequestMapping("api/taxcollect/contribuable")
@RequiredArgsConstructor
public class ContribuableController {

 @Autowired
 private  ContribuableService contribuableService;



    @PostMapping
    public ResponseEntity<ContribuableDto> create(@RequestBody ContribuableDto contribuableDto) {
        ContribuableDto created = contribuableService.create(contribuableDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ContribuableDto> update(@PathVariable Long id,
                                                  @RequestBody ContribuableDto contribuableDto) {
        ContribuableDto updated = contribuableService.update(id, contribuableDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContribuableDto> findById(@PathVariable Long id) {
        ContribuableDto contribuable = contribuableService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<ContribuableDto>> findAll() {
        List<ContribuableDto> contribuableList = contribuableService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<ContribuableDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ContribuableDto> page = contribuableService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<ContribuableDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ContribuableDto> page = contribuableService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
