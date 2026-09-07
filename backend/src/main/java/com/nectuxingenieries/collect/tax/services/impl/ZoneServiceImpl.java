package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.Commune;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.models.mappers.ZoneMapper;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.ZoneService;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.repositories.CommuneRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class ZoneServiceImpl implements ZoneService {

    @Autowired
    private ZoneRepository zoneRepository;
    @Autowired
    private ZoneMapper zoneMapper;
    @Autowired
    private CommuneRepository communeRepository;

    @Override
    public ZoneDto create(ZoneDto zoneDto) {
        Zone entity = zoneMapper.toEntity(zoneDto);
        if (zoneDto.getCommuneId() != null) {
            Commune commune = communeRepository.findById(zoneDto.getCommuneId())
                    .orElseThrow(() -> new RuntimeException("Commune non trouvée"));
            entity.setCommune(commune);
        }
        return zoneMapper.toDto(zoneRepository.save(entity));
    }

    @Override
    public ZoneDto update(Long id, ZoneDto zoneDto) {
        Zone existing = zoneRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Zone non trouvée"));
        zoneMapper.updateFromDto(zoneDto, existing);
        if (zoneDto.getCommuneId() != null) {
            Commune commune = communeRepository.findById(zoneDto.getCommuneId())
                    .orElseThrow(() -> new RuntimeException("Commune non trouvée"));
            existing.setCommune(commune);
        }
        return zoneMapper.toDto(zoneRepository.save(existing));
    }

    @Override
    public Optional<ZoneDto> findById(Long id) {
        return zoneRepository.findById(id)
                .map(zoneMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ZoneDto> findAll() {
        return zoneRepository.findAll()
                .stream()
                .map(zoneMapper::toDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ZoneDto> findAll(Pageable pageable) {
        return zoneRepository.findAll(pageable).map(zoneMapper::toDto);
    }

    @Override
    public Page<ZoneDto> findAll(Map<String, String> filters, Pageable pageable) {
        Specification<Zone> specification = GenericSpecifications.fromMap(filters);
        return zoneRepository.findAll(specification, pageable).map(zoneMapper::toDto);
    }

    @Override
    public void delete(Long id) {
        zoneRepository.deleteById(id);
    }

    @Override
    public void restore(Long id) {
        Zone zone = zoneRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Zone non trouvée"));
        zone.setDeletedAt(null);
        zone.setDeletedBy(null);
        zoneRepository.save(zone);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ZoneDto> findAllIncludingDeleted() {
        return zoneRepository.findAll()
                .stream()
                .map(zoneMapper::toDto)
                .toList();
    }
}
