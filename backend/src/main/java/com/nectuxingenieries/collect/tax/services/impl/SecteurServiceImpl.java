package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Secteur;
import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.dto.SecteurDto;
import com.nectuxingenieries.collect.tax.models.mappers.SecteurMapper;
import com.nectuxingenieries.collect.tax.services.SecteurService;
import com.nectuxingenieries.collect.tax.repositories.SecteurRepository;
import com.nectuxingenieries.collect.tax.repositories.QuartierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class SecteurServiceImpl implements SecteurService {

    @Autowired
    private SecteurRepository secteurRepository;
    @Autowired
    private SecteurMapper secteurMapper;
    @Autowired
    private QuartierRepository quartierRepository;

    @Override
    public SecteurDto create(SecteurDto secteurDto) {
        Secteur entity = secteurMapper.toEntity(secteurDto);
        if (secteurDto.getQuartierId() != null) {
            Quartier quartier = quartierRepository.findById(secteurDto.getQuartierId())
                    .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
            entity.setQuartier(quartier);
        }
        return secteurMapper.toDto(secteurRepository.save(entity));
    }

    @Override
    public SecteurDto update(Long id, SecteurDto secteurDto) {
        Secteur existing = secteurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Secteur non trouvé"));
        secteurMapper.updateFromDto(secteurDto, existing);
        if (secteurDto.getQuartierId() != null) {
            Quartier quartier = quartierRepository.findById(secteurDto.getQuartierId())
                    .orElseThrow(() -> new RuntimeException("Quartier non trouvé"));
            existing.setQuartier(quartier);
        }
        return secteurMapper.toDto(secteurRepository.save(existing));
    }

    @Override
    public Optional<SecteurDto> findById(Long id) {
        return secteurRepository.findById(id)
                .map(secteurMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SecteurDto> findAll() {
        return secteurRepository.findAll()
                .stream()
                .map(secteurMapper::toDto)
                .toList();
    }

    @Override
    public void delete(Long id) {
        secteurRepository.deleteById(id);
    }

    @Override
    public void restore(Long id) {
        Secteur secteur = secteurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Secteur non trouvé"));
        secteur.setDeletedAt(null);
        secteur.setDeletedBy(null);
        secteurRepository.save(secteur);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SecteurDto> findAllIncludingDeleted() {
        return secteurRepository.findAll()
                .stream()
                .map(secteurMapper::toDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SecteurDto> locateByGps(double latitude, double longitude) {
        Secteur secteur = secteurRepository.findByGeometryContaining(latitude, longitude);
        return Optional.ofNullable(secteur).map(secteurMapper::toDto);
    }
}
