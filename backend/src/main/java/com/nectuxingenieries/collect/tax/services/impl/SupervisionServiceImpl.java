package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dto.AgentSummaryDto;
import com.nectuxingenieries.collect.tax.dto.SupervisedZoneDto;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.mappers.ZoneMapper;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.services.AgentService;
import com.nectuxingenieries.collect.tax.services.SupervisionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SupervisionServiceImpl implements SupervisionService {

    @Autowired
    private ZoneRepository zoneRepository;

    @Autowired
    private AgentRepository agentRepository;

    @Autowired
    private AgentService agentService;

    @Autowired
    private ZoneMapper zoneMapper;

    @Override
    @Transactional(readOnly = true)
    public List<SupervisedZoneDto> getSupervisedZones(String superviseurId) {
        List<Zone> zones = zoneRepository.findBySuperviseurId(superviseurId);
        return zones.stream().map(this::toSupervisedZoneDto).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentSummaryDto> getAvailableAgents(String superviseurId) {
        List<Zone> zones = zoneRepository.findBySuperviseurId(superviseurId);
        if (zones.isEmpty()) {
            return agentRepository.findActiveAgents().stream()
                    .map(this::toAgentSummaryDto)
                    .collect(Collectors.toList());
        }
        List<Long> zoneIds = zones.stream().map(Zone::getId).collect(Collectors.toList());
        return agentRepository.findAgentsNotInZones(zoneIds).stream()
                .map(this::toAgentSummaryDto)
                .collect(Collectors.toList());
    }

    @Override
    public void assignAgentToZone(Long zoneId, Long agentId) {
        agentService.assignZoneToAgent(agentId, zoneId);
    }

    @Override
    public void unassignAgentFromZone(Long zoneId, Long agentId) {
        agentService.removeZoneFromAgent(agentId, zoneId);
    }

    @Override
    public ZoneDto assignZoneToSuperviseur(Long zoneId, String superviseurId) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new NotFoundException("Zone", zoneId));
        zone.setSuperviseurId(superviseurId);
        return zoneMapper.toDto(zoneRepository.save(zone));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ZoneDto> getUnassignedZones(String superviseurId) {
        return zoneRepository.findUnassignedZones(superviseurId).stream()
                .map(zoneMapper::toDto)
                .collect(Collectors.toList());
    }

    private SupervisedZoneDto toSupervisedZoneDto(Zone zone) {
        SupervisedZoneDto dto = new SupervisedZoneDto();
        dto.setId(zone.getId());
        dto.setNom(zone.getNom());
        dto.setStatut(zone.getStatut());
        dto.setSuperviseurId(zone.getSuperviseurId());
        if (zone.getCommune() != null) {
            dto.setCommuneNom(zone.getCommune().getNom());
        }
        List<Agents> agents = agentRepository.findByZoneId(zone.getId());
        dto.setAgents(agents.stream().map(this::toAgentSummaryDto).collect(Collectors.toList()));
        return dto;
    }

    private AgentSummaryDto toAgentSummaryDto(Agents agent) {
        AgentSummaryDto dto = new AgentSummaryDto();
        dto.setId(agent.getId());
        dto.setNom(agent.getNom());
        dto.setPrenom(agent.getPrenom());
        dto.setEmail(agent.getEmail());
        dto.setTelephone(agent.getTelephone());
        String initials = "";
        if (agent.getNom() != null && !agent.getNom().isEmpty()) {
            initials += agent.getNom().charAt(0);
        }
        if (agent.getPrenom() != null && !agent.getPrenom().isEmpty()) {
            initials += agent.getPrenom().charAt(0);
        }
        dto.setInitials(initials.toUpperCase());
        return dto;
    }
}
