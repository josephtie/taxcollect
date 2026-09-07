package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.CommuneDto;
import com.nectuxingenieries.collect.tax.services.CommuneService;
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
@RequestMapping("api/taxcollect/commune")
@RequiredArgsConstructor
@Tag(name = "Communes", description = "API de gestion des communes")
public class CommuneController {

    @Autowired
   private  CommuneService communeService;



    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PostMapping
    public ResponseEntity<CommuneDto> create(@RequestBody CommuneDto CommuneDto) {
        CommuneDto created = communeService.create(CommuneDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PutMapping("/{id}")
    public ResponseEntity<CommuneDto> update(@PathVariable Long id,
                                                  @RequestBody CommuneDto CommuneDto) {
        CommuneDto updated = communeService.update(id, CommuneDto);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/{id}")
    public ResponseEntity<CommuneDto> findById(@PathVariable Long id) {
        return communeService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping
    public ResponseEntity<List<CommuneDto>> findAll() {
        List<CommuneDto> communeList = communeService.findAll();
        return ResponseEntity.ok(communeList);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/all")
    public ResponseEntity<List<CommuneDto>> findAllAll() {
        List<CommuneDto> contribuableList = communeService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/page")
    public ResponseEntity<Page<CommuneDto>> findAllPageable(@PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<CommuneDto> page = communeService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/filter")
    public ResponseEntity<Page<CommuneDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<CommuneDto> page = communeService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
