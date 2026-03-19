package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.dto.TaxeDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface TaxeService extends BaseService<Taxe, Long, TaxeDto> {

    // Méthodes spécifiques aux taxes
    Page<TaxeDto> findAll(Pageable pageable);
    Page<TaxeDto> findAll(Map<String,String> filters, Pageable pageable);
    Page<TaxeDto> searchTaxes(String searchTerm, Map<String, String> filters, Pageable pageable);
    List<String> getCategories();
    List<String> getPeriodicites();
    Map<String, Object> getTaxeStats();
    byte[] exportTaxes(String format, String categorie);
    TaxeDto duplicateTaxe(Long id);
}

