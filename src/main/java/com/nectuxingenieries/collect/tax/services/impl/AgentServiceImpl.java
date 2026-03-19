package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.AgentsDto;
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

    @Autowired
    public AgentServiceImpl(AgentRepository agentRepository, AgentsMapper agentMapper, LogicalDeletionPermissions permissions) {
        super(agentRepository, agentMapper::toEntity, agentMapper::toDto, permissions);
        this.agentRepository = agentRepository;
        this.agentMapper = agentMapper;
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
    public AgentsDto updateStatus(Long id, String status) {
        Agents agent = agentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
        agent.setStatut(status);
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getAgentStats(Long id, String startDate, String endDate) {
        Agents agent = agentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
        
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
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
        // TODO: Implémenter l'assignation de zone
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    public AgentsDto removeZoneFromAgent(Long agentId, Long zoneId) {
        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
        // TODO: Implémenter le retrait de zone
        return agentMapper.toDto(agentRepository.save(agent));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentsDto> getAgentsByZone(Long zoneId) {
        return agentRepository.findByZoneCollecteId(zoneId)
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
