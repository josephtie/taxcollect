package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Anomalie;
import com.nectuxingenieries.collect.tax.dto.AnomalieDto;
import com.nectuxingenieries.collect.tax.models.mappers.AnomalieMapper;
import com.nectuxingenieries.collect.tax.services.AnomalieService;
import com.nectuxingenieries.collect.tax.repositories.AnomalieRepository;
import com.nectuxingenieries.collect.tax.models.enums.StatutAnomalie;
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
public class AnomalieServiceImpl implements AnomalieService {

    @Autowired
    private AnomalieRepository anomalieRepository;
    @Autowired
    private AnomalieMapper anomalieMapper;

    @Override
    public AnomalieDto create(AnomalieDto dto) {
        Anomalie entity = anomalieMapper.toEntity(dto);
        entity.setStatut(StatutAnomalie.OUVERTE);
        return anomalieMapper.toDto(anomalieRepository.save(entity));
    }

    @Override
    public Optional<AnomalieDto> findById(Long id) {
        return anomalieRepository.findById(id).map(anomalieMapper::toDto);
    }

    @Override
    public List<AnomalieDto> findByQuartierId(Long quartierId) {
        return anomalieRepository.findByQuartierId(quartierId).stream()
                .map(anomalieMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AnomalieDto> findByQuartierIdAndStatut(Long quartierId, String statut) {
        return anomalieRepository.findByQuartierIdAndStatut(quartierId, StatutAnomalie.valueOf(statut)).stream()
                .map(anomalieMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AnomalieDto> findByStatut(String statut) {
        return anomalieRepository.findByStatut(StatutAnomalie.valueOf(statut)).stream()
                .map(anomalieMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AnomalieDto> findByAgentId(Long agentId) {
        return anomalieRepository.findByAgentId(agentId).stream()
                .map(anomalieMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public AnomalieDto documenter(Long id, String commentaire) {
        Anomalie a = anomalieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anomalie non trouvée"));
        a.setCommentaireSuperviseur(commentaire);
        if (a.getStatut() == StatutAnomalie.OUVERTE) {
            a.setStatut(StatutAnomalie.EN_COURS);
        }
        return anomalieMapper.toDto(anomalieRepository.save(a));
    }

    @Override
    public AnomalieDto transmettre(Long id, String commentaire) {
        Anomalie a = anomalieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anomalie non trouvée"));
        a.setStatut(StatutAnomalie.TRANSMISE);
        a.setTransmiseA("SUPERVISEUR");
        a.setDateTransmission(LocalDateTime.now());
        if (commentaire != null) {
            a.setCommentaireSuperviseur(commentaire);
        }
        return anomalieMapper.toDto(anomalieRepository.save(a));
    }

    @Override
    public AnomalieDto affecterAction(Long id, Long agentId, String action) {
        Anomalie a = anomalieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anomalie non trouvée"));
        a.setAgentId(agentId);
        a.setAction(action);
        if (a.getStatut() == StatutAnomalie.OUVERTE) {
            a.setStatut(StatutAnomalie.EN_COURS);
        }
        return anomalieMapper.toDto(anomalieRepository.save(a));
    }

    @Override
    public AnomalieDto clôturer(Long id, Long clotureePar, String commentaire) {
        Anomalie a = anomalieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anomalie non trouvée"));
        a.setStatut(StatutAnomalie.CLOTUREE);
        a.setDateCloture(LocalDateTime.now());
        a.setClotureePar(clotureePar);
        if (commentaire != null) {
            a.setCommentaireSuperviseur(commentaire);
        }
        return anomalieMapper.toDto(anomalieRepository.save(a));
    }

    @Override
    public AnomalieDto escaler(Long id, String commentaire) {
        Anomalie a = anomalieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anomalie non trouvée"));
        a.setStatut(StatutAnomalie.ESCALEE);
        a.setTransmiseA("HIERARCHIE");
        a.setDateTransmission(LocalDateTime.now());
        if (commentaire != null) {
            a.setCommentaireSuperviseur(commentaire);
        }
        return anomalieMapper.toDto(anomalieRepository.save(a));
    }

    @Override
    public void delete(Long id) {
        anomalieRepository.deleteLogical(id, "system");
    }
}
