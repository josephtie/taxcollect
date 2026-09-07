package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.AgentsDto;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.StatutAgent;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.mappers.AgentsMapper;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.security.LogicalDeletionPermissions;
import com.nectuxingenieries.collect.tax.services.impl.AgentServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AgentServiceImplTest {

    @Mock
    private AgentRepository agentRepository;

    @Mock
    private AgentsMapper agentMapper;

    @Mock
    private LogicalDeletionPermissions permissions;

    @Mock
    private ZoneRepository zoneRepository;

    @InjectMocks
    private AgentServiceImpl agentService;

    private Agents agent;
    private Zone zone1;
    private Zone zone2;
    private AgentsDto agentDto;

    @BeforeEach
    void setUp() {
        agent = new Agents();
        agent.setId(1L);
        agent.setNom("Kabasele");
        agent.setPrenom("Joseph");
        agent.setEmail("joseph@taxcollect.cd");
        agent.setTelephone("+243812345678");
        agent.setStatut(StatutAgent.ACTIF);
        agent.setZones(new ArrayList<>());

        zone1 = new Zone();
        zone1.setId(10L);
        zone1.setNom("Marché central");

        zone2 = new Zone();
        zone2.setId(20L);
        zone2.setNom("Quartier commercial");

        agentDto = new AgentsDto();
        agentDto.setId(1L);
        agentDto.setNom("Kabasele");
        agentDto.setPrenom("Joseph");
    }

    @Test
    void assignZoneToAgent_shouldAddZone_whenNotAlreadyAssigned() {
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(zoneRepository.findById(10L)).thenReturn(Optional.of(zone1));
        when(agentRepository.save(any(Agents.class))).thenReturn(agent);
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        AgentsDto result = agentService.assignZoneToAgent(1L, 10L);

        assertNotNull(result);
        assertEquals(1, agent.getZones().size());
        assertTrue(agent.getZones().stream().anyMatch(z -> z.getId().equals(10L)));
        verify(agentRepository).save(agent);
    }

    @Test
    void assignZoneToAgent_shouldThrowNotFound_whenAgentDoesNotExist() {
        when(agentRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> agentService.assignZoneToAgent(99L, 10L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void assignZoneToAgent_shouldThrowNotFound_whenZoneDoesNotExist() {
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(zoneRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> agentService.assignZoneToAgent(1L, 99L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void assignZoneToAgent_shouldThrowInvalidOperation_whenZoneAlreadyAssigned() {
        agent.getZones().add(zone1);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(zoneRepository.findById(10L)).thenReturn(Optional.of(zone1));

        assertThrows(InvalidOperationException.class, () -> agentService.assignZoneToAgent(1L, 10L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void assignZoneToAgent_shouldInitializeZoneList_whenNull() {
        agent.setZones(null);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(zoneRepository.findById(10L)).thenReturn(Optional.of(zone1));
        when(agentRepository.save(any(Agents.class))).thenReturn(agent);
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        AgentsDto result = agentService.assignZoneToAgent(1L, 10L);

        assertNotNull(result);
        assertNotNull(agent.getZones());
        assertEquals(1, agent.getZones().size());
    }

    @Test
    void assignZoneToAgent_shouldAllowMultipleZones() {
        agent.getZones().add(zone1);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(zoneRepository.findById(20L)).thenReturn(Optional.of(zone2));
        when(agentRepository.save(any(Agents.class))).thenReturn(agent);
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        AgentsDto result = agentService.assignZoneToAgent(1L, 20L);

        assertNotNull(result);
        assertEquals(2, agent.getZones().size());
    }

    @Test
    void removeZoneFromAgent_shouldRemoveZone_whenAssigned() {
        agent.getZones().add(zone1);
        agent.getZones().add(zone2);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(agentRepository.save(any(Agents.class))).thenReturn(agent);
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        AgentsDto result = agentService.removeZoneFromAgent(1L, 10L);

        assertNotNull(result);
        assertEquals(1, agent.getZones().size());
        assertFalse(agent.getZones().stream().anyMatch(z -> z.getId().equals(10L)));
        verify(agentRepository).save(agent);
    }

    @Test
    void removeZoneFromAgent_shouldThrowNotFound_whenAgentDoesNotExist() {
        when(agentRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> agentService.removeZoneFromAgent(99L, 10L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void removeZoneFromAgent_shouldThrowInvalidOperation_whenZoneNotAssigned() {
        agent.getZones().add(zone1);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));

        assertThrows(InvalidOperationException.class, () -> agentService.removeZoneFromAgent(1L, 20L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void removeZoneFromAgent_shouldThrowInvalidOperation_whenZoneListNull() {
        agent.setZones(null);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));

        assertThrows(InvalidOperationException.class, () -> agentService.removeZoneFromAgent(1L, 10L));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void updateStatus_shouldUpdateStatut() {
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(agentRepository.save(any(Agents.class))).thenReturn(agent);
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        AgentsDto result = agentService.updateStatus(1L, StatutAgent.SUSPENDU);

        assertNotNull(result);
        assertEquals(StatutAgent.SUSPENDU, agent.getStatut());
        verify(agentRepository).save(agent);
    }

    @Test
    void updateStatus_shouldThrowNotFound_whenAgentDoesNotExist() {
        when(agentRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> agentService.updateStatus(99L, StatutAgent.SUSPENDU));
        verify(agentRepository, never()).save(any());
    }

    @Test
    void getAgentsByZone_shouldReturnAgents() {
        agent.getZones().add(zone1);
        when(agentRepository.findByZoneId(10L)).thenReturn(Arrays.asList(agent));
        when(agentMapper.toDto(any(Agents.class))).thenReturn(agentDto);

        List<AgentsDto> result = agentService.getAgentsByZone(10L);

        assertEquals(1, result.size());
        assertEquals("Kabasele", result.get(0).getNom());
    }

    @Test
    void getAgentsByZone_shouldReturnEmptyList_whenNoAgents() {
        when(agentRepository.findByZoneId(99L)).thenReturn(List.of());

        List<AgentsDto> result = agentService.getAgentsByZone(99L);

        assertTrue(result.isEmpty());
    }
}
