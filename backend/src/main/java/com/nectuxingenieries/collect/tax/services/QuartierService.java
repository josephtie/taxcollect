package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface QuartierService {
    QuartierDto create(QuartierDto quartierDto);
    QuartierDto update(Long id, QuartierDto quartierDto);
    Optional<QuartierDto> findById(Long id);
    List<QuartierDto> findAll();
    Page<QuartierDto> findAll(Pageable pageable);
    Page<QuartierDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
    void restore(Long id);
    List<QuartierDto> findAllIncludingDeleted();
}
