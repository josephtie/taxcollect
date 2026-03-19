package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.AgentsDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface AgentService extends BaseService<Agents, Long, AgentsDto> {
    // Méthodes spécifiques aux agents
    Page<AgentsDto> findAll(Pageable pageable);
    Page<AgentsDto> findAll(Map<String,String> filters, Pageable pageable);
    List<AgentsDto> findActiveAgents();
    Page<AgentsDto> searchAgents(String searchTerm, Map<String, String> filters, Pageable pageable);
    AgentsDto updateStatus(Long id, String status);
    Map<String, Object> getAgentStats(Long id, String startDate, String endDate);
    Page<Object> getAgentTransactions(Long id, String startDate, String endDate, Pageable pageable);
    AgentsDto assignZoneToAgent(Long agentId, Long zoneId);
    AgentsDto removeZoneFromAgent(Long agentId, Long zoneId);
    List<AgentsDto> getAgentsByZone(Long zoneId);
}

