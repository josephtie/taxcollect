package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.SupervisedZoneDto;
import com.nectuxingenieries.collect.tax.dto.AgentSummaryDto;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;

import java.util.List;

public interface SupervisionService {
    List<SupervisedZoneDto> getSupervisedZones(String superviseurId);
    List<AgentSummaryDto> getAvailableAgents(String superviseurId);
    void assignAgentToZone(Long zoneId, Long agentId);
    void unassignAgentFromZone(Long zoneId, Long agentId);
    ZoneDto assignZoneToSuperviseur(Long zoneId, String superviseurId);
    List<ZoneDto> getUnassignedZones(String superviseurId);
}
