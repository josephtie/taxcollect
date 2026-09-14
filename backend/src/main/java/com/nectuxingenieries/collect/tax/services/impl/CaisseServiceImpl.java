package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Caisse;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.CaisseDto;
import com.nectuxingenieries.collect.tax.models.mappers.CaisseMapper;
import com.nectuxingenieries.collect.tax.services.CaisseService;
import com.nectuxingenieries.collect.tax.repositories.CaisseRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class CaisseServiceImpl implements CaisseService {

    @Autowired
    private CaisseRepository caisseRepository;
    @Autowired
    private CaisseMapper caisseMapper;
    @Autowired
    private AgentRepository agentRepository;

    @Override
    public CaisseDto create(CaisseDto caisseDto) {
        Caisse entity = caisseMapper.toEntity(caisseDto);
        if (caisseDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(caisseDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            entity.setAgent(agent);
        }
        if (entity.getDateCaisse() == null) {
            entity.setDateCaisse(LocalDate.now());
        }
        return caisseMapper.toDto(caisseRepository.save(entity));
    }

    @Override
    public Optional<CaisseDto> findById(Long id) {
        return caisseRepository.findById(id).map(caisseMapper::toDto);
    }

    @Override
    public List<CaisseDto> findAll() {
        return caisseRepository.findAll().stream()
                .map(caisseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<CaisseDto> findByAgentId(Long agentId) {
        return caisseRepository.findByAgentId(agentId).stream()
                .map(caisseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public Optional<CaisseDto> findByAgentAndDate(Long agentId, LocalDate date) {
        return caisseRepository.findByAgentAndDate(agentId, date).map(caisseMapper::toDto);
    }

    @Override
    public CaisseDto ouvrirCaisse(Long id) {
        Caisse caisse = caisseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Caisse non trouvée"));
        caisse.setStatut(com.nectuxingenieries.collect.tax.models.enums.StatutCaisse.OUVERTE);
        caisse.setDateOuverture(LocalDateTime.now());
        return caisseMapper.toDto(caisseRepository.save(caisse));
    }

    @Override
    public CaisseDto cloturerCaisse(Long id) {
        Caisse caisse = caisseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Caisse non trouvée"));
        caisse.setStatut(com.nectuxingenieries.collect.tax.models.enums.StatutCaisse.CLOTUREE);
        caisse.setDateCloture(LocalDateTime.now());
        return caisseMapper.toDto(caisseRepository.save(caisse));
    }

    @Override
    public void delete(Long id) {
        caisseRepository.deleteLogical(id, "system");
    }
}
