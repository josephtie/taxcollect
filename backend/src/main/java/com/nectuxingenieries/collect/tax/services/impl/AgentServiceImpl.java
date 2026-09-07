package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.StatutAgent;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.dto.AgentsDto;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.models.mappers.AgentsMapper;
import com.nectuxingenieries.collect.tax.security.LogicalDeletionPermissions;
import com.nectuxingenieries.collect.tax.services.AgentService;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
public class AgentServiceImpl extends BaseServiceImpl<Agents, Long, AgentsDto, AgentRepository> implements AgentService {

    private final AgentRepository agentRepository;
    private final AgentsMapper agentMapper;
    private final ZoneRepository zoneRepository;

    @Autowired
    public AgentServiceImpl(AgentRepository agentRepository, AgentsMapper agentMapper, LogicalDeletionPermissions permissions, ZoneRepository zoneRepository) {
        super(agentRepository, agentMapper::toEntity, agentMapper::toDto, permissions);
        this.agentRepository = agentRepository;
        this.agentMapper = agentMapper;
        this.zoneRepository = zoneRepository;
    }

    // Méthodes spécifiques aux agents
    @Override
    @Transactional(readOnly = true)
    public Page<AgentsDto> findAll(Pageable pageable) {
        return agentRepository.findAll(pageable).map(agentMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AgentsDto> findAll(Map<String, String> filters, Pageable pageable) {
        Specification<Agents> specification = GenericSpecifications.fromMap(filters);
        return agentRepository.findAll(specification, pageable).map(agentMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentsDto> findActiveAgents() {
        return agentRepository.findActiveAgents()
                .stream()
                .map(agentMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AgentsDto> searchAgents(String searchTerm, Map<String, String> filters, Pageable pageable) {
        Specification<Agents> specification = Specification.where(null);
        
        // Recherche par nom ou prénom
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            specification = specification.and((root, query, criteriaBuilder) ->
                criteriaBuilder.or(
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("nom")),
                        "%" + searchTerm.toLowerCase() + "%"
                    ),
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("prenom")),
                        "%" + searchTerm.toLowerCase() + "%"
                    )
                )
            );
        }
        
        return agentRepository.findAll(specification, pageable).map(agentMapper::toDto);
    }

    @Override
    public AgentsDto updateStatus(Long id, StatutAgent status) {
        Agents agent = agentRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Agent", id));
        agent.setStatut(status);
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getAgentStats(Long id, String startDate, String endDate) {
        Agents agent = agentRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Agent", id));
        
        Map<String, Object> stats = Map.of("agent", agentMapper.toDto(agent));
        
        // Ajouter des statistiques spécifiques si nécessaire
        // TODO: Implémenter les statistiques détaillées
        
        return stats;
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Object> getAgentTransactions(Long id, String startDate, String endDate, Pageable pageable) {
        // TODO: Implémenter la récupération des transactions
        return Page.empty();
    }

    @Override
    public AgentsDto assignZoneToAgent(Long agentId, Long zoneId) {
        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new NotFoundException("Agent", agentId));
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new NotFoundException("Zone", zoneId));

        if (agent.getZones() == null) {
            agent.setZones(new java.util.ArrayList<>());
        }
        if (agent.getZones().stream().anyMatch(z -> z.getId().equals(zoneId))) {
            throw new InvalidOperationException("La zone " + zoneId + " est déjà assignée à l'agent " + agentId);
        }
        agent.getZones().add(zone);
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    public AgentsDto removeZoneFromAgent(Long agentId, Long zoneId) {
        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new NotFoundException("Agent", agentId));

        if (agent.getZones() == null || agent.getZones().stream().noneMatch(z -> z.getId().equals(zoneId))) {
            throw new InvalidOperationException("La zone " + zoneId + " n'est pas assignée à l'agent " + agentId);
        }
        agent.getZones().removeIf(z -> z.getId().equals(zoneId));
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentsDto> getAgentsByZone(Long zoneId) {
        return agentRepository.findByZoneId(zoneId)
                .stream()
                .map(agentMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    protected void updateEntityFromDto(Agents entity, AgentsDto dto) {
        // Utiliser le mapper pour mettre à jour l'entité
        agentMapper.updateFromDto(dto, entity);
    }
}
