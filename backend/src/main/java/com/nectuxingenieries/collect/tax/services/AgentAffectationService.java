package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.AgentAffectationDto;
import com.nectuxingenieries.collect.tax.dto.EffectivePerimeterDto;
import com.nectuxingenieries.collect.tax.models.TerritoryType;

import java.util.List;

public interface AgentAffectationService {

    AgentAffectationDto assign(Long agentId, TerritoryType territoryType, Long territoryId);

    void unassign(Long agentId, TerritoryType territoryType, Long territoryId);

    List<AgentAffectationDto> getAffectationsByTerritory(TerritoryType territoryType, Long territoryId);

    List<AgentAffectationDto> getAffectationsByAgent(Long agentId);

    EffectivePerimeterDto getEffectivePerimeter(Long agentId);

    List<Long> getAvailableAgentIds(TerritoryType territoryType, Long territoryId);
}
