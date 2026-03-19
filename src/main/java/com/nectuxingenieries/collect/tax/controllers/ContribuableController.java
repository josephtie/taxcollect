package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
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
        return contribuableService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
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

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        contribuableService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public ResponseEntity<Page<ContribuableDto>> searchContribuables(@RequestParam String searchTerm,
                                                                      @RequestParam(required = false) Map<String, String> filters,
                                                                      @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ContribuableDto> searchResults = contribuableService.searchContribuables(searchTerm, filters, pageable);
        return ResponseEntity.ok(searchResults);
    }

    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<List<ContribuableDto>> getContribuablesByZone(@PathVariable Long zoneId) {
        List<ContribuableDto> contribuables = contribuableService.getContribuablesByZone(zoneId);
        return ResponseEntity.ok(contribuables);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getContribuableStats() {
        Map<String, Object> stats = contribuableService.getContribuableStats();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/export")
    public ResponseEntity<byte[]> exportContribuables(@RequestParam(required = false) String format,
                                                      @RequestParam(required = false) Long zoneId) {
        byte[] exportData = contribuableService.exportContribuables(format, zoneId);
        String filename = "contribuables_" + new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + 
                         (format != null && format.equals("csv") ? ".csv" : ".xlsx");
        
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
                .header("Content-Type", format != null && format.equals("csv") ? "text/csv" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(exportData);
    }
}
