package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.CommuneDto;
import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface CommuneService {
    CommuneDto create(CommuneDto communeDto);
    CommuneDto update(Long id, CommuneDto communeDto);
    Optional<CommuneDto> findById(Long id);
    List<CommuneDto> findAll();
    Page<CommuneDto> findAll(Pageable pageable);
    Page<CommuneDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}
