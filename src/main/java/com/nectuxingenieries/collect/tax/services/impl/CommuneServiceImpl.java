package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dao.CommuneRepository;
import com.nectuxingenieries.collect.tax.models.Commune;
import com.nectuxingenieries.collect.tax.models.dto.CommuneDto;
import com.nectuxingenieries.collect.tax.models.mappers.CommuneMapper;
import com.nectuxingenieries.collect.tax.services.CommuneService;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
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
public class CommuneServiceImpl implements CommuneService {

    @Autowired
 private  CommuneRepository communeRepository;
    @Autowired private  CommuneMapper communeMapper;



    @Override
    public CommuneDto create(CommuneDto communeDto) {
        Commune entity = communeMapper.toEntity(communeDto);
        return communeMapper.toDto(communeRepository.save(entity));
    }
    @Override
    public CommuneDto update(Long id, CommuneDto communeDto) {
        Commune existing = communeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Commune non trouvée"));
        communeMapper.updateFromDto(communeDto, existing);
        return communeMapper.toDto(communeRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public CommuneDto findById(Long id) {
        return communeRepository.findById(id)
                .map(communeMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Commune non trouvée"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<CommuneDto> findAll() {
        return communeRepository.findAll()
                .stream()
                .map(communeMapper::toDto)
                .toList();
    }
    @Override
    @Transactional(readOnly = true)
    public Page<CommuneDto> findAll(Pageable pageable) {
        return communeRepository.findAll(pageable).map(communeMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        communeRepository.deleteById(id);
    }

    @Override
    public Page<CommuneDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Commune> specification = GenericSpecifications.fromMap(filters);
        return communeRepository.findAll(specification, pageable).map(communeMapper::toDto);
    }
}

