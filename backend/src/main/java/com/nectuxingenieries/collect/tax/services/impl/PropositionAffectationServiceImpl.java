package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.PropositionAffectation;
import com.nectuxingenieries.collect.tax.dto.PropositionAffectationDto;
import com.nectuxingenieries.collect.tax.models.enums.StatutProposition;
import com.nectuxingenieries.collect.tax.services.PropositionAffectationService;
import com.nectuxingenieries.collect.tax.repositories.PropositionAffectationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class PropositionAffectationServiceImpl implements PropositionAffectationService {

    @Autowired
    private PropositionAffectationRepository propositionRepository;

    private PropositionAffectationDto toDto(PropositionAffectation p) {
        PropositionAffectationDto dto = new PropositionAffectationDto();
        dto.setId(p.getId());
        dto.setAgentId(p.getAgentId());
        dto.setAgentNom(p.getAgentNom());
        dto.setSecteurId(p.getSecteurId());
        dto.setSecteurNom(p.getSecteurNom());
        dto.setQuartierId(p.getQuartierId());
        dto.setProposeParId(p.getProposeParId());
        dto.setProposeParRole(p.getProposeParRole());
        dto.setMotif(p.getMotif());
        dto.setStatut(p.getStatut());
        dto.setValideePar(p.getValideePar());
        dto.setDateValidation(p.getDateValidation());
        dto.setCommentaireValidation(p.getCommentaireValidation());
        dto.setCreatedAt(p.getCreatedAt());
        return dto;
    }

    @Override
    public PropositionAffectationDto create(PropositionAffectationDto dto) {
        PropositionAffectation entity = new PropositionAffectation();
        entity.setAgentId(dto.getAgentId());
        entity.setAgentNom(dto.getAgentNom());
        entity.setSecteurId(dto.getSecteurId());
        entity.setSecteurNom(dto.getSecteurNom());
        entity.setQuartierId(dto.getQuartierId());
        entity.setProposeParId(dto.getProposeParId());
        entity.setProposeParRole(dto.getProposeParRole());
        entity.setMotif(dto.getMotif());
        entity.setStatut(StatutProposition.EN_ATTENTE);
        return toDto(propositionRepository.save(entity));
    }

    @Override
    public Optional<PropositionAffectationDto> findById(Long id) {
        return propositionRepository.findById(id).map(this::toDto);
    }

    @Override
    public List<PropositionAffectationDto> findByQuartierId(Long quartierId) {
        return propositionRepository.findByQuartierId(quartierId).stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public List<PropositionAffectationDto> findByQuartierIdAndStatut(Long quartierId, String statut) {
        return propositionRepository.findByQuartierIdAndStatut(quartierId, StatutProposition.valueOf(statut)).stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public List<PropositionAffectationDto> findByStatut(String statut) {
        return propositionRepository.findByStatut(StatutProposition.valueOf(statut)).stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public PropositionAffectationDto valider(Long id, Long valideePar, String commentaire) {
        PropositionAffectation p = propositionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Proposition non trouvée"));
        p.setStatut(StatutProposition.VALIDEE);
        p.setValideePar(valideePar);
        p.setDateValidation(LocalDateTime.now());
        p.setCommentaireValidation(commentaire);
        return toDto(propositionRepository.save(p));
    }

    @Override
    public PropositionAffectationDto rejeter(Long id, Long valideePar, String commentaire) {
        PropositionAffectation p = propositionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Proposition non trouvée"));
        p.setStatut(StatutProposition.REJETEE);
        p.setValideePar(valideePar);
        p.setDateValidation(LocalDateTime.now());
        p.setCommentaireValidation(commentaire);
        return toDto(propositionRepository.save(p));
    }

    @Override
    public void delete(Long id) {
        propositionRepository.deleteLogical(id, "system");
    }
}
