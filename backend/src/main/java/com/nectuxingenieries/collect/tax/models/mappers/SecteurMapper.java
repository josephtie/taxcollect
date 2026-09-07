package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Secteur;
import com.nectuxingenieries.collect.tax.dto.SecteurDto;
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
public interface SecteurMapper {

    @Mapping(source = "quartier.nom", target = "quartierNom")
    @Mapping(source = "geometry", target = "geometryGeoJson", qualifiedByName = "multiPolygonToGeoJson")
    SecteurDto toDto(Secteur secteur);

    @Mapping(target = "quartier", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    Secteur toEntity(SecteurDto secteurDto);

    @Mapping(target = "quartier", ignore = true)
    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    void updateFromDto(SecteurDto secteurDto, @MappingTarget Secteur secteur);

    @Named("multiPolygonToGeoJson")
    default String multiPolygonToGeoJson(MultiPolygon multiPolygon) {
        return GeometryConverter.multiPolygonToGeoJson(multiPolygon);
    }

    @Named("geoJsonToMultiPolygon")
    default MultiPolygon geoJsonToMultiPolygon(String geoJson) {
        return GeometryConverter.geoJsonToMultiPolygon(geoJson);
    }
}
