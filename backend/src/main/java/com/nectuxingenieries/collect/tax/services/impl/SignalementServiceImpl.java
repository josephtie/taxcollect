package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Signalement;
import com.nectuxingenieries.collect.tax.dto.SignalementDto;
import com.nectuxingenieries.collect.tax.models.mappers.SignalementMapper;
import com.nectuxingenieries.collect.tax.services.SignalementService;
import com.nectuxingenieries.collect.tax.repositories.SignalementRepository;
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
public class SignalementServiceImpl implements SignalementService {

    @Autowired
    private SignalementRepository signalementRepository;
    @Autowired
    private SignalementMapper signalementMapper;

    @Override
    public SignalementDto create(SignalementDto signalementDto) {
        Signalement entity = signalementMapper.toEntity(signalementDto);
        return signalementMapper.toDto(signalementRepository.save(entity));
    }

    @Override
    public Optional<SignalementDto> findById(Long id) {
        return signalementRepository.findById(id).map(signalementMapper::toDto);
    }

    @Override
    public List<SignalementDto> findAll() {
        return signalementRepository.findAll().stream()
                .map(signalementMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<SignalementDto> findByAgentId(Long agentId) {
        return signalementRepository.findByAgentId(agentId).stream()
                .map(signalementMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<SignalementDto> findByStatut(String statut) {
        return signalementRepository.findByStatut(statut).stream()
                .map(signalementMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public SignalementDto traiter(Long id, String reponse, Long traitePar) {
        Signalement signalement = signalementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Signalement non trouvé"));
        signalement.setReponse(reponse);
        signalement.setTraitePar(traitePar);
        signalement.setStatut("TRAITE");
        signalement.setDateTraitement(LocalDateTime.now());
        return signalementMapper.toDto(signalementRepository.save(signalement));
    }

    @Override
    public void delete(Long id) {
        signalementRepository.deleteLogical(id, "system");
    }
}
