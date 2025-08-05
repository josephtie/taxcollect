package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.ContribuableDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface ContribuableService {
    ContribuableDto create(ContribuableDto contribuableDto);
    ContribuableDto update(Long id, ContribuableDto contribuableDto);
    ContribuableDto findById(Long id);
    List<ContribuableDto> findAll();
    Page<ContribuableDto> findAll(Pageable pageable);
    Page<ContribuableDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}

