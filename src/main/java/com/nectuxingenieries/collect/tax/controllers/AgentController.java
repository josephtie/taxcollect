package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.AgentsDto;
import com.nectuxingenieries.collect.tax.services.AgentService;
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
@RequestMapping("api/taxcollect/agent")
@RequiredArgsConstructor
public class AgentController {

    @Autowired
 private  AgentService agentService;



    @PostMapping
    public ResponseEntity<AgentsDto> create(@RequestBody AgentsDto agentsDto) {
        AgentsDto created = agentService.create(agentsDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AgentsDto> update(@PathVariable Long id,
                                                  @RequestBody AgentsDto agentsDto) {
        AgentsDto updated = agentService.update(id, agentsDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AgentsDto> findById(@PathVariable Long id) {
        AgentsDto contribuable = agentService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<AgentsDto>> findAll() {
        List<AgentsDto> contribuableList = agentService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<AgentsDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<AgentsDto> page = agentService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<AgentsDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<AgentsDto> page = agentService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
