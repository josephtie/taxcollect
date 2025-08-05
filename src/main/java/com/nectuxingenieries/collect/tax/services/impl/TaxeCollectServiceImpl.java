package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dao.TaxeCollectRepository;
import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.models.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.models.mappers.TaxeCollectMapper;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.TaxeCollectService;
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
public class TaxeCollectServiceImpl implements TaxeCollectService {

    @Autowired
   private  TaxeCollectRepository taxeCollectRepository;
    @Autowired  private  TaxeCollectMapper taxeCollectMapper;



    @Override
    public TaxeCollectDto create(TaxeCollectDto taxeCollectDto) {
        TaxeCollect entity = taxeCollectMapper.toEntity(taxeCollectDto);
        return taxeCollectMapper.toDto(taxeCollectRepository.save(entity));
    }
    @Override
    public TaxeCollectDto update(Long id, TaxeCollectDto taxeCollectDto) {
        TaxeCollect existing = taxeCollectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
        taxeCollectMapper.updateFromDto(taxeCollectDto, existing);
        return taxeCollectMapper.toDto(taxeCollectRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public TaxeCollectDto findById(Long id) {
        return taxeCollectRepository.findById(id)
                .map(taxeCollectMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<TaxeCollectDto> findAll() {
        return taxeCollectRepository.findAll()
                .stream()
                .map(taxeCollectMapper::toDto)
                .toList();
    }
    @Override
    @Transactional(readOnly = true)
    public Page<TaxeCollectDto> findAll(Pageable pageable) {
        return taxeCollectRepository.findAll(pageable).map(taxeCollectMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        taxeCollectRepository.deleteById(id);
    }


    @Override
    public Page<TaxeCollectDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<TaxeCollect> specification = GenericSpecifications.fromMap(filters);
        return taxeCollectRepository.findAll(specification, pageable).map(taxeCollectMapper::toDto);
    }
}
