package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.dto.QuartierDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.Named;
import org.locationtech.jts.geom.MultiPolygon;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface QuartierMapper {

    @Mapping(source = "zone.nom", target = "zoneNom")
    @Mapping(source = "zone.commune.nom", target = "communeNom")
    @Mapping(source = "geometry", target = "geometryGeoJson", qualifiedByName = "multiPolygonToGeoJson")
    QuartierDto toDto(Quartier quartier);

    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    Quartier toEntity(QuartierDto quartierDto);

    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    void updateFromDto(QuartierDto quartierDto, @MappingTarget Quartier quartier);

    @Named("multiPolygonToGeoJson")
    default String multiPolygonToGeoJson(MultiPolygon multiPolygon) {
        return GeometryConverter.multiPolygonToGeoJson(multiPolygon);
    }

    @Named("geoJsonToMultiPolygon")
    default MultiPolygon geoJsonToMultiPolygon(String geoJson) {
        return GeometryConverter.geoJsonToMultiPolygon(geoJson);
    }
}

