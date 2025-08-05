package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.CommuneDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface CommuneService {
    CommuneDto create(CommuneDto communeDto);
    CommuneDto update(Long id, CommuneDto communeDto);
    CommuneDto findById(Long id);
    List<CommuneDto> findAll();
    Page<CommuneDto> findAll(Pageable pageable);
    Page<CommuneDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}
