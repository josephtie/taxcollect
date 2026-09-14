package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.TourneeDto;
import com.nectuxingenieries.collect.tax.services.TourneeService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("api/taxcollect/tournee")
@RequiredArgsConstructor
@Tag(name = "Tournées", description = "API de gestion des tournées de collecte")
public class TourneeController {

    private final TourneeService tourneeService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<TourneeDto>> findAll() {
        return ResponseEntity.ok(tourneeService.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<TourneeDto> findById(@PathVariable Long id) {
        return tourneeService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<TourneeDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(tourneeService.findByAgentId(agentId));
    }

    @GetMapping("/date/{date}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<TourneeDto>> findByDate(@PathVariable LocalDate date) {
        return ResponseEntity.ok(tourneeService.findByDate(date));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<TourneeDto> create(@RequestBody TourneeDto tourneeDto) {
        TourneeDto created = tourneeService.create(tourneeDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<TourneeDto> update(@PathVariable Long id, @RequestBody TourneeDto tourneeDto) {
        return ResponseEntity.ok(tourneeService.update(id, tourneeDto));
    }

    @PostMapping("/{id}/demarrer")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<TourneeDto> demarrer(@PathVariable Long id) {
        return ResponseEntity.ok(tourneeService.demarrerTournee(id));
    }

    @PostMapping("/{id}/terminer")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<TourneeDto> terminer(@PathVariable Long id) {
        return ResponseEntity.ok(tourneeService.terminerTournee(id));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        tourneeService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        tourneeService.restore(id);
        return ResponseEntity.ok().build();
    }
}
