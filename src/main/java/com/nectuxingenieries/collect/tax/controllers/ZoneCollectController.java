package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.ZoneCollectDto;
import com.nectuxingenieries.collect.tax.services.ZoneCollecteService;
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
@RequestMapping("api/taxcollect/zonecollect")
@RequiredArgsConstructor
public class ZoneCollectController {

    @Autowired
  private  ZoneCollecteService zoneCollecteService;



    @PostMapping
    public ResponseEntity<ZoneCollectDto> create(@RequestBody ZoneCollectDto zoneCollectDto) {
        ZoneCollectDto created = zoneCollecteService.create(zoneCollectDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ZoneCollectDto> update(@PathVariable Long id,
                                                  @RequestBody ZoneCollectDto zoneCollectDto) {
        ZoneCollectDto updated = zoneCollecteService.update(id, zoneCollectDto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ZoneCollectDto> findById(@PathVariable Long id) {
        ZoneCollectDto contribuable = zoneCollecteService.findById(id);
        return ResponseEntity.ok(contribuable);
    }

    @GetMapping("/all")
    public ResponseEntity<List<ZoneCollectDto>> findAll() {
        List<ZoneCollectDto> contribuableList = zoneCollecteService.findAll();
        return ResponseEntity.ok(contribuableList);
    }

    @GetMapping("/page")
    public ResponseEntity<Page<ZoneCollectDto>> findAllPageable( @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ZoneCollectDto> page = zoneCollecteService.findAll(pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<ZoneCollectDto>> findAllFiltered(@RequestParam Map<String,String> filters,
                                                                 @PageableDefault(size = 20, sort = "nom", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ZoneCollectDto> page = zoneCollecteService.findAll(filters, pageable);
        return ResponseEntity.ok(page);
    }
}
