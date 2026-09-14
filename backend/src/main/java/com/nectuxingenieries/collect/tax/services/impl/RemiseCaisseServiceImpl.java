package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.RemiseCaisse;
import com.nectuxingenieries.collect.tax.models.Caisse;
import com.nectuxingenieries.collect.tax.dto.RemiseCaisseDto;
import com.nectuxingenieries.collect.tax.models.mappers.RemiseCaisseMapper;
import com.nectuxingenieries.collect.tax.services.RemiseCaisseService;
import com.nectuxingenieries.collect.tax.repositories.RemiseCaisseRepository;
import com.nectuxingenieries.collect.tax.repositories.CaisseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class RemiseCaisseServiceImpl implements RemiseCaisseService {

    @Autowired
    private RemiseCaisseRepository remiseRepository;
    @Autowired
    private RemiseCaisseMapper remiseMapper;
    @Autowired
    private CaisseRepository caisseRepository;

    @Override
    public RemiseCaisseDto create(RemiseCaisseDto remiseDto) {
        RemiseCaisse entity = remiseMapper.toEntity(remiseDto);
        if (remiseDto.getCaisseId() != null) {
            Caisse caisse = caisseRepository.findById(remiseDto.getCaisseId())
                    .orElseThrow(() -> new RuntimeException("Caisse non trouvée"));
            entity.setCaisse(caisse);
        }
        return remiseMapper.toDto(remiseRepository.save(entity));
    }

    @Override
    public Optional<RemiseCaisseDto> findById(Long id) {
        return remiseRepository.findById(id).map(remiseMapper::toDto);
    }

    @Override
    public List<RemiseCaisseDto> findAll() {
        return remiseRepository.findAll().stream()
                .map(remiseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<RemiseCaisseDto> findByCaisseId(Long caisseId) {
        return remiseRepository.findByCaisseId(caisseId).stream()
                .map(remiseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<RemiseCaisseDto> findByStatut(String statut) {
        return remiseRepository.findByStatut(statut).stream()
                .map(remiseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<RemiseCaisseDto> findByAgentId(Long agentId) {
        return remiseRepository.findByAgentId(agentId).stream()
                .map(remiseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public RemiseCaisseDto confirmer(Long id, Long confirmePar, String commentaire) {
        RemiseCaisse remise = remiseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Remise de caisse non trouvée"));
        remise.setStatut("CONFIRMEE");
        remise.setConfirmePar(confirmePar);
        remise.setDateConfirmation(LocalDateTime.now());
        remise.setCommentaireConfirmation(commentaire);
        return remiseMapper.toDto(remiseRepository.save(remise));
    }

    @Override
    public void delete(Long id) {
        remiseRepository.deleteLogical(id, "system");
    }
}
