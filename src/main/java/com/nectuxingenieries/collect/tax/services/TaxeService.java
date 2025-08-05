package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.TaxeDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface TaxeService {

    TaxeDto create(TaxeDto taxeDto);
    TaxeDto update(Long id, TaxeDto taxeDto);
    TaxeDto findById(Long id);
    List<TaxeDto> findAll();
    Page<TaxeDto> findAll(Pageable pageable);
    void delete(Long id);

    Page<TaxeDto> findAll(Map<String,String> filters, Pageable pageable);
}

