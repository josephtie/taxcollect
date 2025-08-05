package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dao.ContribuableRepository;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.dto.ContribuableDto;
import com.nectuxingenieries.collect.tax.models.mappers.ContribuableMapper;
import com.nectuxingenieries.collect.tax.services.ContribuableService;
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
public class ContribuableServiceImpl implements ContribuableService {

    @Autowired
  private  ContribuableRepository contribuableRepository;
    @Autowired private  ContribuableMapper contribuableMapper;



    @Override
    public ContribuableDto create(ContribuableDto contribuableDto) {
        Contribuable entity = contribuableMapper.toEntity(contribuableDto);
        return contribuableMapper.toDto(contribuableRepository.save(entity));
    }
    @Override
    public ContribuableDto update(Long id, ContribuableDto contribuableDto) {
        Contribuable existing = contribuableRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
        contribuableMapper.updateFromDto(contribuableDto, existing);
        return contribuableMapper.toDto(contribuableRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public ContribuableDto findById(Long id) {
        return contribuableRepository.findById(id)
                .map(contribuableMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<ContribuableDto> findAll() {
        return contribuableRepository.findAll()
                .stream()
                .map(contribuableMapper::toDto)
                .toList();
    }

    @Override
    public Page<ContribuableDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Contribuable> specification = GenericSpecifications.fromMap(filters);
        return contribuableRepository.findAll(specification, pageable).map(contribuableMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ContribuableDto> findAll(Pageable pageable) {
        return contribuableRepository.findAll(pageable).map(contribuableMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        contribuableRepository.deleteById(id);
    }
}
