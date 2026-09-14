package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.PromessePaiement;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.PromessePaiementDto;
import com.nectuxingenieries.collect.tax.models.mappers.PromessePaiementMapper;
import com.nectuxingenieries.collect.tax.services.PromessePaiementService;
import com.nectuxingenieries.collect.tax.repositories.PromessePaiementRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class PromessePaiementServiceImpl implements PromessePaiementService {

    @Autowired
    private PromessePaiementRepository promesseRepository;
    @Autowired
    private PromessePaiementMapper promesseMapper;
    @Autowired
    private ContribuableRepository contribuableRepository;
    @Autowired
    private AgentRepository agentRepository;

    @Override
    public PromessePaiementDto create(PromessePaiementDto promesseDto) {
        PromessePaiement entity = promesseMapper.toEntity(promesseDto);
        if (promesseDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(promesseDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            entity.setContribuable(contribuable);
        }
        if (promesseDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(promesseDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            entity.setAgent(agent);
        }
        return promesseMapper.toDto(promesseRepository.save(entity));
    }

    @Override
    public PromessePaiementDto update(Long id, PromessePaiementDto promesseDto) {
        PromessePaiement existing = promesseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promesse non trouvée"));
        promesseMapper.updateFromDto(promesseDto, existing);
        if (promesseDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(promesseDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            existing.setContribuable(contribuable);
        }
        if (promesseDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(promesseDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            existing.setAgent(agent);
        }
        return promesseMapper.toDto(promesseRepository.save(existing));
    }

    @Override
    public Optional<PromessePaiementDto> findById(Long id) {
        return promesseRepository.findById(id).map(promesseMapper::toDto);
    }

    @Override
    public List<PromessePaiementDto> findAll() {
        return promesseRepository.findAll().stream()
                .map(promesseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<PromessePaiementDto> findByContribuableId(Long contribuableId) {
        return promesseRepository.findByContribuableId(contribuableId).stream()
                .map(promesseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<PromessePaiementDto> findByAgentId(Long agentId) {
        return promesseRepository.findByAgentId(agentId).stream()
                .map(promesseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<PromessePaiementDto> findEcheancesProches(LocalDate date) {
        return promesseRepository.findEcheancesProches(date).stream()
                .map(promesseMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Long id) {
        promesseRepository.deleteLogical(id, "system");
    }

    @Override
    public void restore(Long id) {
        promesseRepository.restore(id);
    }

    @Override
    public PromessePaiementDto marquerRelance(Long id) {
        PromessePaiement promesse = promesseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promesse non trouvée"));
        promesse.setRelanceEffectuee(true);
        return promesseMapper.toDto(promesseRepository.save(promesse));
    }

    @Override
    public PromessePaiementDto marquerHonoree(Long id) {
        PromessePaiement promesse = promesseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promesse non trouvée"));
        promesse.setStatut("HONOREE");
        return promesseMapper.toDto(promesseRepository.save(promesse));
    }
}
