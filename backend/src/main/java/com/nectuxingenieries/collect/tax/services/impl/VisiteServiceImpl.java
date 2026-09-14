package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Visite;
import com.nectuxingenieries.collect.tax.models.Tournee;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.dto.VisiteDto;
import com.nectuxingenieries.collect.tax.models.mappers.VisiteMapper;
import com.nectuxingenieries.collect.tax.services.VisiteService;
import com.nectuxingenieries.collect.tax.repositories.VisiteRepository;
import com.nectuxingenieries.collect.tax.repositories.TourneeRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class VisiteServiceImpl implements VisiteService {

    @Autowired
    private VisiteRepository visiteRepository;
    @Autowired
    private VisiteMapper visiteMapper;
    @Autowired
    private TourneeRepository tourneeRepository;
    @Autowired
    private ContribuableRepository contribuableRepository;

    @Override
    public VisiteDto create(VisiteDto visiteDto) {
        Visite entity = visiteMapper.toEntity(visiteDto);
        if (visiteDto.getTourneeId() != null) {
            Tournee tournee = tourneeRepository.findById(visiteDto.getTourneeId())
                    .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));
            entity.setTournee(tournee);
        }
        if (visiteDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(visiteDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            entity.setContribuable(contribuable);
        }
        return visiteMapper.toDto(visiteRepository.save(entity));
    }

    @Override
    public VisiteDto update(Long id, VisiteDto visiteDto) {
        Visite existing = visiteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Visite non trouvée"));
        visiteMapper.updateFromDto(visiteDto, existing);
        if (visiteDto.getTourneeId() != null) {
            Tournee tournee = tourneeRepository.findById(visiteDto.getTourneeId())
                    .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));
            existing.setTournee(tournee);
        }
        if (visiteDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(visiteDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            existing.setContribuable(contribuable);
        }
        return visiteMapper.toDto(visiteRepository.save(existing));
    }

    @Override
    public Optional<VisiteDto> findById(Long id) {
        return visiteRepository.findById(id).map(visiteMapper::toDto);
    }

    @Override
    public List<VisiteDto> findAll() {
        return visiteRepository.findAll().stream()
                .map(visiteMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<VisiteDto> findByTourneeId(Long tourneeId) {
        return visiteRepository.findByTourneeId(tourneeId).stream()
                .map(visiteMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<VisiteDto> findByContribuableId(Long contribuableId) {
        return visiteRepository.findByContribuableId(contribuableId).stream()
                .map(visiteMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Long id) {
        visiteRepository.deleteLogical(id, "system");
    }

    @Override
    public void restore(Long id) {
        visiteRepository.restore(id);
    }

    @Override
    public VisiteDto updateStatut(Long id, String statut, String motif, String observation) {
        Visite visite = visiteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Visite non trouvée"));
        visite.setStatut(com.nectuxingenieries.collect.tax.models.enums.StatutVisite.valueOf(statut));
        if (motif != null && !motif.isEmpty()) {
            visite.setMotif(com.nectuxingenieries.collect.tax.models.enums.MotifVisite.valueOf(motif));
        }
        if (observation != null) {
            visite.setObservation(observation);
        }
        return visiteMapper.toDto(visiteRepository.save(visite));
    }
}
