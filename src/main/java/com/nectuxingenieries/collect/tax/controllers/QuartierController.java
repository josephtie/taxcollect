package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.QuartierDto;
import com.nectuxingenieries.collect.tax.services.QuartierService;
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
@RequestMapping("api/taxcollect/quartier")
@RequiredArgsConstructor
public class QuartierController {

@Autowired
private QuartierService quartierService;



    @PostMapping
    public ResponseEntity<QuartierDto> create(@RequestBody QuartierDto quartierDto) {
        QuartierDto created = quartierService.create(quartierDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<QuartierDto> update(@PathVariable Long id,
                                                  @RequestBody QuartierDto quartierDto) {
        QuartierDto updated = quartierService.update(id, quartierDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuartierDto> findById(@PathVariable Long id) {
        QuartierDto contribuable = quartierService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<QuartierDto>> findAll() {
        List<QuartierDto> contribuableList = quartierService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<QuartierDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<QuartierDto> page = quartierService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<QuartierDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<QuartierDto> page = quartierService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
