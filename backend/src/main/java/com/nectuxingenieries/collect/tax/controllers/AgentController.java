package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.AgentsDto;
import com.nectuxingenieries.collect.tax.dto.PageResponse;
import com.nectuxingenieries.collect.tax.models.StatutAgent;
import com.nectuxingenieries.collect.tax.services.AgentService;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
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
@RequestMapping("api/taxcollect/agent")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
@Tag(name = "Agents", description = "API de gestion des agents de collecte")
public class AgentController {

    @Autowired
    private AgentService agentService;

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PostMapping
    public ResponseEntity<AgentsDto> create(@RequestBody AgentsDto agentsDto) {
        AgentsDto created = agentService.create(agentsDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PutMapping("/{id}")
    public ResponseEntity<AgentsDto> update(@PathVariable Long id,
                                                  @RequestBody AgentsDto agentsDto) {
        AgentsDto updated = agentService.update(id, agentsDto);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/{id}")
    public ResponseEntity<AgentsDto> findById(@PathVariable Long id) {
        AgentsDto agent = agentService.findById(id)
                .orElseThrow(() -> new com.nectuxingenieries.collect.tax.exceptions.NotFoundException("Agent", id));
        return ResponseEntity.ok(agent);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/all")
    public ResponseEntity<List<AgentsDto>> findAll() {
        List<AgentsDto> contribuableList = agentService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    @Operation(summary = "Lister tous les agents (paginé)", description = "Retourne tous les agents avec pagination")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<PageResponse<AgentsDto>> findAllPageable(
            @Parameter(description = "Numéro de page (0-based)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Taille de la page") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "Tri") @RequestParam(defaultValue = "nom,asc") String sort) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<AgentsDto> agentPage = agentService.findAll(pageable);
        
        PageResponse<AgentsDto> response = new PageResponse<>(
            agentPage.getContent(),
            agentPage.getNumber(),
            agentPage.getSize(),
            agentPage.getTotalElements(),
            agentPage.getTotalPages()
        );
        
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/filter")
    public ResponseEntity<Page<AgentsDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<AgentsDto> page = agentService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        agentService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{id}/restore")
    public ResponseEntity<Void> restore(@PathVariable Long id) {
        agentService.restore(id);
        return ResponseEntity.ok().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/including-deleted")
    public ResponseEntity<List<AgentsDto>> findAllIncludingDeleted() {
        return ResponseEntity.ok(agentService.findAllIncludingDeleted());
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/active")
    public ResponseEntity<List<AgentsDto>> findActiveAgents() {
        List<AgentsDto> activeAgents = agentService.findActiveAgents();
        return ResponseEntity.ok(activeAgents);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR')")
    @GetMapping("/search")
    public ResponseEntity<Page<AgentsDto>> searchAgents(@RequestParam String searchTerm,
                                                          @RequestParam(required = false) Map<String, String> filters,
                                                          @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<AgentsDto> searchResults = agentService.searchAgents(searchTerm, filters, pageable);
        return ResponseEntity.ok(searchResults);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    @PutMapping("/{id}/status")
    public ResponseEntity<AgentsDto> updateAgentStatus(@PathVariable Long id, @RequestParam StatutAgent status) {
        AgentsDto updated = agentService.updateStatus(id, status);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/{id}/stats")
    @Hidden
    public ResponseEntity<Map<String, Object>> getAgentStats(@PathVariable Long id,
                                                              @RequestParam(required = false) String startDate,
                                                              @RequestParam(required = false) String endDate) {
        Map<String, Object> stats = agentService.getAgentStats(id, startDate, endDate);
        return ResponseEntity.ok(stats);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/{id}/transactions")
    @Hidden
    public ResponseEntity<Page<Object>> getAgentTransactions(@PathVariable Long id,
                                                              @RequestParam(required = false) String startDate,
                                                              @RequestParam(required = false) String endDate,
                                                              @PageableDefault(size = 20, sort = "dateTransaction", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<Object> transactions = agentService.getAgentTransactions(id, startDate, endDate, pageable);
        return ResponseEntity.ok(transactions);
    }

    @PostMapping("/{agentId}/zones/{zoneId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<AgentsDto> assignZoneToAgent(@PathVariable Long agentId, @PathVariable Long zoneId) {
        AgentsDto updated = agentService.assignZoneToAgent(agentId, zoneId);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{agentId}/zones/{zoneId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<AgentsDto> removeZoneFromAgent(@PathVariable Long agentId, @PathVariable Long zoneId) {
        AgentsDto updated = agentService.removeZoneFromAgent(agentId, zoneId);
        return ResponseEntity.ok(updated);
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'TRESOR', 'AGENT')")
    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<List<AgentsDto>> getAgentsByZone(@PathVariable Long zoneId) {
        List<AgentsDto> agents = agentService.getAgentsByZone(zoneId);
        return ResponseEntity.ok(agents);
    }
}
