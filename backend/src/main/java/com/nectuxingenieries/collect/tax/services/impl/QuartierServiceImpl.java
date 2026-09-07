package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.repositories.QuartierRepository;
import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import com.nectuxingenieries.collect.tax.models.mappers.QuartierMapper;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.QuartierService;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
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
public class QuartierServiceImpl implements QuartierService {

    @Autowired
  private  QuartierRepository quartierRepository;
    @Autowired  private  QuartierMapper quartierMapper;
    @Autowired
    private ZoneRepository zoneRepository;



    @Override
    public QuartierDto create(QuartierDto quartierDto) {
        Quartier entity = quartierMapper.toEntity(quartierDto);
        if (quartierDto.getZoneId() != null) {
            Zone zone = zoneRepository.findById(quartierDto.getZoneId())
                    .orElseThrow(() -> new RuntimeException("Zone non trouvée"));
            entity.setZone(zone);
        }
        return quartierMapper.toDto(quartierRepository.save(entity));
    }
    @Override
    public QuartierDto update(Long id, QuartierDto quartierDto) {
        Quartier existing = quartierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
        quartierMapper.updateFromDto(quartierDto, existing);
        if (quartierDto.getZoneId() != null) {
            Zone zone = zoneRepository.findById(quartierDto.getZoneId())
                    .orElseThrow(() -> new RuntimeException("Zone non trouvée"));
            existing.setZone(zone);
        }
        return quartierMapper.toDto(quartierRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public Optional<QuartierDto> findById(Long id) {
        return quartierRepository.findById(id)
                .map(quartierMapper::toDto);
               // .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<QuartierDto> findAll() {
        return quartierRepository.findAll()
                .stream()
                .map(quartierMapper::toDto)
                .toList();
    }
    @Override
    @Transactional(readOnly = true)
    public Page<QuartierDto> findAll(Pageable pageable) {
        return quartierRepository.findAll(pageable).map(quartierMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        quartierRepository.deleteById(id);
    }

    @Override
    public Page<QuartierDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Quartier> specification = GenericSpecifications.fromMap(filters);
        return quartierRepository.findAll(specification, pageable).map(quartierMapper::toDto);
    }

    @Override
    public void restore(Long id) {
        Quartier quartier = quartierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
        quartier.setDeletedAt(null);
        quartier.setDeletedBy(null);
        quartierRepository.save(quartier);
    }

    @Override
    public List<QuartierDto> findAllIncludingDeleted() {
        return quartierRepository.findAll()
                .stream()
                .map(quartierMapper::toDto)
                .toList();
    }

}
