package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dao.TaxeRepository;
import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.models.dto.TaxeDto;
import com.nectuxingenieries.collect.tax.models.mappers.TaxeMapper;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.TaxeService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@Transactional
@RequiredArgsConstructor
public class TaxeServiceImpl implements TaxeService {

    @Autowired
 private  TaxeRepository taxeRepository;
    @Autowired   private  TaxeMapper taxeMapper;



    @Override
    public TaxeDto create(TaxeDto taxeDto) {
        Taxe taxe = taxeMapper.toEntity(taxeDto);
        return taxeMapper.toDto(taxeRepository.save(taxe));
    }

    @Override
    public TaxeDto update(Long id, TaxeDto taxeDto) {
        Taxe existing = taxeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Taxe non trouvée"));
        taxeMapper.updateFromDto(taxeDto, existing);
        return taxeMapper.toDto(taxeRepository.save(existing));
    }

    @Override
    @Transactional(readOnly = true)
    public TaxeDto findById(Long id) {
        return taxeRepository.findById(id)
                .map(taxeMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Taxe non trouvée"));
    }

    @Override
    @Transactional(readOnly = true)
    public List<TaxeDto> findAll() {
        return taxeRepository.findAll()
                .stream()
                .map(taxeMapper::toDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TaxeDto> findAll(Pageable pageable) {
        return taxeRepository.findAll(pageable).map(taxeMapper::toDto);
    }

    @Override
    public void delete(Long id) {
        taxeRepository.deleteById(id);
    }

    @Override
    public Page<TaxeDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Taxe> specification = GenericSpecifications.fromMap(filters);
        return taxeRepository.findAll(specification, pageable).map(taxeMapper::toDto);
    }
}

