package com.nectuxingenieries.collect.tax.services.impl;


import com.nectuxingenieries.collect.tax.dao.ZoneCollectRepository;
import com.nectuxingenieries.collect.tax.models.ZoneCollecte;
import com.nectuxingenieries.collect.tax.models.dto.ZoneCollectDto;
import com.nectuxingenieries.collect.tax.models.mappers.ZoneCollecteMapper;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.ZoneCollecteService;
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
public class ZoneCollecteServiceImpl implements ZoneCollecteService {

    @Autowired
 private  ZoneCollectRepository zoneCollecteRepository;
    @Autowired private  ZoneCollecteMapper zoneCollecteMapper;



    @Override
    public ZoneCollectDto create(ZoneCollectDto zoneCollecteDto) {
        ZoneCollecte entity = zoneCollecteMapper.toEntity(zoneCollecteDto);
        return zoneCollecteMapper.toDto(zoneCollecteRepository.save(entity));
    }
    @Override
    public ZoneCollectDto update(Long id, ZoneCollectDto zoneCollecteDto) {
        ZoneCollecte existing = zoneCollecteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Zone de collecte non trouvée"));
        zoneCollecteMapper.updateFromDto(zoneCollecteDto, existing);
        return zoneCollecteMapper.toDto(zoneCollecteRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public ZoneCollectDto findById(Long id) {
        return zoneCollecteRepository.findById(id)
                .map(zoneCollecteMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Zone de collecte non trouvée"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<ZoneCollectDto> findAll() {
        return zoneCollecteRepository.findAll()
                .stream()
                .map(zoneCollecteMapper::toDto)
                .toList();
    }
    @Override
    @Transactional(readOnly = true)
    public Page<ZoneCollectDto> findAll(Pageable pageable) {
        return zoneCollecteRepository.findAll(pageable).map(zoneCollecteMapper::toDto);
    }

    @Override
    public Page<ZoneCollectDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<ZoneCollecte> specification = GenericSpecifications.fromMap(filters);
        return zoneCollecteRepository.findAll(specification, pageable).map(zoneCollecteMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        zoneCollecteRepository.deleteById(id);
    }
}
