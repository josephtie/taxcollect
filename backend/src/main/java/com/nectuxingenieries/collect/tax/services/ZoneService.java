package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ZoneService {
    ZoneDto create(ZoneDto zoneDto);
    ZoneDto update(Long id, ZoneDto zoneDto);
    Optional<ZoneDto> findById(Long id);
    List<ZoneDto> findAll();
    Page<ZoneDto> findAll(Pageable pageable);
    Page<ZoneDto> findAll(Map<String, String> filters, Pageable pageable);
    void delete(Long id);
    void restore(Long id);
    List<ZoneDto> findAllIncludingDeleted();
}
