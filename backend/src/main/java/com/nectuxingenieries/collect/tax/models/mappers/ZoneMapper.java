package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.ZoneDto;
import com.nectuxingenieries.collect.tax.dto.AgentSummaryDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.Named;
import org.locationtech.jts.geom.MultiPolygon;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface ZoneMapper {

    @Mapping(source = "commune.nom", target = "communeNom")
    @Mapping(source = "commune.id", target = "communeId")
    @Mapping(source = "geometry", target = "geometryGeoJson", qualifiedByName = "multiPolygonToGeoJson")
    @Mapping(source = "agents", target = "agents", qualifiedByName = "agentsToSummaries")
    ZoneDto toDto(Zone zone);

    @Mapping(target = "commune", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    Zone toEntity(ZoneDto zoneDto);

    @Mapping(target = "commune", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    void updateFromDto(ZoneDto zoneDto, @MappingTarget Zone zone);

    @Named("multiPolygonToGeoJson")
    default String multiPolygonToGeoJson(MultiPolygon multiPolygon) {
        return GeometryConverter.multiPolygonToGeoJson(multiPolygon);
    }

    @Named("geoJsonToMultiPolygon")
    default MultiPolygon geoJsonToMultiPolygon(String geoJson) {
        return GeometryConverter.geoJsonToMultiPolygon(geoJson);
    }

    @Named("agentsToSummaries")
    default List<AgentSummaryDto> agentsToSummaries(List<Agents> agents) {
        if (agents == null) return null;
        return agents.stream().map(agent -> {
            AgentSummaryDto dto = new AgentSummaryDto();
            dto.setId(agent.getId());
            dto.setNom(agent.getNom());
            dto.setPrenom(agent.getPrenom());
            dto.setEmail(agent.getEmail());
            dto.setTelephone(agent.getTelephone());
            String initials = "";
            if (agent.getPrenom() != null && !agent.getPrenom().isEmpty()) initials += agent.getPrenom().charAt(0);
            if (agent.getNom() != null && !agent.getNom().isEmpty()) initials += agent.getNom().charAt(0);
            dto.setInitials(initials.toUpperCase());
            return dto;
        }).collect(Collectors.toList());
    }
}
