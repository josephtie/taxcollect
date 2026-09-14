package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Portefeuille;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.dto.PortefeuilleDto;
import com.nectuxingenieries.collect.tax.models.mappers.PortefeuilleMapper;
import com.nectuxingenieries.collect.tax.services.PortefeuilleService;
import com.nectuxingenieries.collect.tax.repositories.PortefeuilleRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
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
public class PortefeuilleServiceImpl implements PortefeuilleService {

    @Autowired
    private PortefeuilleRepository portefeuilleRepository;
    @Autowired
    private PortefeuilleMapper portefeuilleMapper;
    @Autowired
    private AgentRepository agentRepository;
    @Autowired
    private ContribuableRepository contribuableRepository;

    @Override
    public PortefeuilleDto create(PortefeuilleDto portefeuilleDto) {
        Portefeuille entity = portefeuilleMapper.toEntity(portefeuilleDto);
        if (portefeuilleDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(portefeuilleDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            entity.setAgent(agent);
        }
        if (portefeuilleDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(portefeuilleDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            entity.setContribuable(contribuable);
        }
        if (entity.getDateAffectation() == null) {
            entity.setDateAffectation(LocalDate.now());
        }
        return portefeuilleMapper.toDto(portefeuilleRepository.save(entity));
    }

    @Override
    public PortefeuilleDto update(Long id, PortefeuilleDto portefeuilleDto) {
        Portefeuille existing = portefeuilleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Portefeuille non trouvé"));
        portefeuilleMapper.updateFromDto(portefeuilleDto, existing);
        if (portefeuilleDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(portefeuilleDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            existing.setAgent(agent);
        }
        if (portefeuilleDto.getContribuableId() != null) {
            Contribuable contribuable = contribuableRepository.findById(portefeuilleDto.getContribuableId())
                    .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
            existing.setContribuable(contribuable);
        }
        return portefeuilleMapper.toDto(portefeuilleRepository.save(existing));
    }

    @Override
    public Optional<PortefeuilleDto> findById(Long id) {
        return portefeuilleRepository.findById(id).map(portefeuilleMapper::toDto);
    }

    @Override
    public List<PortefeuilleDto> findAll() {
        return portefeuilleRepository.findAll().stream()
                .map(portefeuilleMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<PortefeuilleDto> findByAgentId(Long agentId) {
        return portefeuilleRepository.findActiveByAgentId(agentId).stream()
                .map(portefeuilleMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<PortefeuilleDto> findByContribuableId(Long contribuableId) {
        return portefeuilleRepository.findActiveByContribuableId(contribuableId).stream()
                .map(portefeuilleMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Long id) {
        portefeuilleRepository.deleteLogical(id, "system");
    }

    @Override
    public void restore(Long id) {
        portefeuilleRepository.restore(id);
    }

    @Override
    public void desaffecter(Long id) {
        Portefeuille portefeuille = portefeuilleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Portefeuille non trouvé"));
        portefeuille.setStatut(false);
        portefeuille.setDateFin(LocalDate.now());
        portefeuilleRepository.save(portefeuille);
    }
}
