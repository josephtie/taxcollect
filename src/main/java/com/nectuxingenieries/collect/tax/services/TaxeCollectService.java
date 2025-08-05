package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.TaxeCollectDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface TaxeCollectService {

    TaxeCollectDto create(TaxeCollectDto taxeCollectDto);
    TaxeCollectDto update(Long id, TaxeCollectDto taxeCollectDto);
    TaxeCollectDto findById(Long id);
    List<TaxeCollectDto> findAll();
    Page<TaxeCollectDto> findAll(Pageable pageable);
    Page<TaxeCollectDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}

