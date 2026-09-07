package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dto.AgentAffectationDto;
import com.nectuxingenieries.collect.tax.dto.EffectivePerimeterDto;
import com.nectuxingenieries.collect.tax.dto.EffectivePerimeterDto.TerritoryRef;
import com.nectuxingenieries.collect.tax.models.AgentAffectation;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.models.Secteur;
import com.nectuxingenieries.collect.tax.models.TerritoryType;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.repositories.AgentAffectationRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.QuartierRepository;
import com.nectuxingenieries.collect.tax.repositories.SecteurRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.services.AgentAffectationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
public class AgentAffectationServiceImpl implements AgentAffectationService {

    @Autowired
    private AgentAffectationRepository affectationRepository;

    @Autowired
    private AgentRepository agentRepository;

    @Autowired
    private ZoneRepository zoneRepository;

    @Autowired
    private QuartierRepository quartierRepository;

    @Autowired
    private SecteurRepository secteurRepository;

    @Override
    public AgentAffectationDto assign(Long agentId, TerritoryType territoryType, Long territoryId) {
        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));

        AgentAffectation affectation = affectationRepository
                .findAnyAssignment(agentId, territoryType, territoryId)
                .orElseGet(() -> {
                    AgentAffectation created = new AgentAffectation();
                    created.setAgent(agent);
                    created.setTerritoryType(territoryType);
                    created.setTerritoryId(territoryId);
                    return created;
                });

        affectation.setStatut(true);
        affectation.setDateFin(null);
        affectation.setDeletedAt(null);
        affectation.setDeletedBy(null);
        affectation.setIsActive(true);
        if (affectation.getDateDebut() == null) {
            affectation.setDateDebut(LocalDate.now());
        }

        return toDto(affectationRepository.save(affectation));
    }

    @Override
    public void unassign(Long agentId, TerritoryType territoryType, Long territoryId) {
        affectationRepository.findActiveAssignment(agentId, territoryType, territoryId)
                .ifPresent(affectation -> {
                    affectation.setStatut(false);
                    affectation.setDateFin(LocalDate.now());
                    affectationRepository.save(affectation);
                });
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentAffectationDto> getAffectationsByTerritory(TerritoryType territoryType, Long territoryId) {
        return affectationRepository.findActiveByTerritory(territoryType, territoryId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentAffectationDto> getAffectationsByAgent(Long agentId) {
        return affectationRepository.findActiveByAgent(agentId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public EffectivePerimeterDto getEffectivePerimeter(Long agentId) {
        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));

        List<AgentAffectation> affectations = affectationRepository.findActiveByAgent(agentId);

        Set<Long> zoneIds = new HashSet<>();
        Set<Long> quartierIds = new HashSet<>();
        Set<Long> secteurIds = new HashSet<>();

        for (AgentAffectation aff : affectations) {
            switch (aff.getTerritoryType()) {
                case ZONE:
                    zoneIds.add(aff.getTerritoryId());
                    break;
                case QUARTIER:
                    quartierIds.add(aff.getTerritoryId());
                    break;
                case SECTEUR:
                    secteurIds.add(aff.getTerritoryId());
                    break;
            }
        }

        // Expand zones into quartiers and secteurs
        for (Long zoneId : zoneIds) {
            List<Quartier> quartiers = quartierRepository.findByZoneId(zoneId);
            for (Quartier q : quartiers) {
                quartierIds.add(q.getId());
            }
        }

        // Expand quartiers into secteurs
        for (Long quartierId : quartierIds) {
            List<Secteur> secteurs = secteurRepository.findByQuartierId(quartierId);
            for (Secteur s : secteurs) {
                secteurIds.add(s.getId());
            }
        }

        List<TerritoryRef> territories = new ArrayList<>();

        for (Long id : zoneIds) {
            zoneRepository.findById(id).ifPresent(z -> {
                TerritoryRef ref = new TerritoryRef();
                ref.setType(TerritoryType.ZONE);
                ref.setId(z.getId());
                ref.setNom(z.getNom());
                territories.add(ref);
            });
        }
        for (Long id : quartierIds) {
            quartierRepository.findById(id).ifPresent(q -> {
                TerritoryRef ref = new TerritoryRef();
                ref.setType(TerritoryType.QUARTIER);
                ref.setId(q.getId());
                ref.setNom(q.getNom());
                territories.add(ref);
            });
        }
        for (Long id : secteurIds) {
            secteurRepository.findById(id).ifPresent(s -> {
                TerritoryRef ref = new TerritoryRef();
                ref.setType(TerritoryType.SECTEUR);
                ref.setId(s.getId());
                ref.setNom(s.getNom());
                territories.add(ref);
            });
        }

        EffectivePerimeterDto dto = new EffectivePerimeterDto();
        dto.setAgentId(agentId);
        dto.setAgentNom(agent.getNom());
        dto.setAgentPrenom(agent.getPrenom());
        dto.setTerritories(territories);
        return dto;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Long> getAvailableAgentIds(TerritoryType territoryType, Long territoryId) {
        List<AgentAffectation> assigned = affectationRepository.findActiveByTerritory(territoryType, territoryId);
        Set<Long> assignedAgentIds = assigned.stream()
                .map(a -> a.getAgent().getId())
                .collect(Collectors.toSet());

        return agentRepository.findAll().stream()
                .filter(a -> a.getDeletedAt() == null)
                .map(Agents::getId)
                .filter(id -> !assignedAgentIds.contains(id))
                .collect(Collectors.toList());
    }

    private AgentAffectationDto toDto(AgentAffectation affectation) {
        AgentAffectationDto dto = new AgentAffectationDto();
        dto.setId(affectation.getId());
        Agents agent = affectation.getAgent();
        dto.setAgentId(agent.getId());
        dto.setAgentNom(agent.getNom());
        dto.setAgentPrenom(agent.getPrenom());
        dto.setAgentEmail(agent.getEmail());
        dto.setAgentTelephone(agent.getTelephone());
        String initials = "";
        if (agent.getPrenom() != null && !agent.getPrenom().isEmpty()) initials += agent.getPrenom().charAt(0);
        if (agent.getNom() != null && !agent.getNom().isEmpty()) initials += agent.getNom().charAt(0);
        dto.setAgentInitials(initials.toUpperCase());
        dto.setTerritoryType(affectation.getTerritoryType());
        dto.setTerritoryId(affectation.getTerritoryId());
        dto.setDateDebut(affectation.getDateDebut());
        dto.setDateFin(affectation.getDateFin());
        dto.setStatut(affectation.getStatut());

        // Resolve territory name
        String nom = switch (affectation.getTerritoryType()) {
            case ZONE -> zoneRepository.findById(affectation.getTerritoryId())
                    .map(Zone::getNom).orElse("Zone #" + affectation.getTerritoryId());
            case QUARTIER -> quartierRepository.findById(affectation.getTerritoryId())
                    .map(Quartier::getNom).orElse("Quartier #" + affectation.getTerritoryId());
            case SECTEUR -> secteurRepository.findById(affectation.getTerritoryId())
                    .map(Secteur::getNom).orElse("Secteur #" + affectation.getTerritoryId());
        };
        dto.setTerritoryNom(nom);

        return dto;
    }
}
