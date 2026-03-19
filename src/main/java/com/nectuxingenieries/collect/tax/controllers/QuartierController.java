package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import com.nectuxingenieries.collect.tax.services.QuartierService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/quartier")
@RequiredArgsConstructor
@Tag(name = "Quartiers", description = "API de gestion des quartiers")
public class QuartierController {

    private final QuartierService quartierService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<QuartierDto>> findAll() {
        List<QuartierDto> quartiers = quartierService.findAll();
        return ResponseEntity.ok(quartiers);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<QuartierDto> findById(@PathVariable Long id) {
        return quartierService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<QuartierDto> create(@RequestBody QuartierDto quartierDto) {
        QuartierDto created = quartierService.create(quartierDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<QuartierDto> update(@PathVariable Long id, @RequestBody QuartierDto quartierDto) {
        QuartierDto updated = quartierService.update(id, quartierDto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        quartierService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        quartierService.restore(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/including-deleted")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<List<QuartierDto>> findAllIncludingDeleted() {
        List<QuartierDto> quartiers = quartierService.findAllIncludingDeleted();
        return ResponseEntity.ok(quartiers);
    }
}
