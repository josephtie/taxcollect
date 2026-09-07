package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Commune;
import com.nectuxingenieries.collect.tax.dto.CommuneDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.locationtech.jts.geom.MultiPolygon;

@Mapper(componentModel = "spring")
public interface CommuneMapper {

    @Mapping(source = "geometry", target = "geometryGeoJson", qualifiedByName = "multiPolygonToGeoJson")
    CommuneDto toDto(Commune commune);

    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    Commune toEntity(CommuneDto communeDto);

    @Mapping(target = "geometry", source = "geometryGeoJson", qualifiedByName = "geoJsonToMultiPolygon")
    void updateFromDto(CommuneDto communeDto, @MappingTarget Commune commune);

    @Named("multiPolygonToGeoJson")
    default String multiPolygonToGeoJson(MultiPolygon multiPolygon) {
        return GeometryConverter.multiPolygonToGeoJson(multiPolygon);
    }

    @Named("geoJsonToMultiPolygon")
    default MultiPolygon geoJsonToMultiPolygon(String geoJson) {
        return GeometryConverter.geoJsonToMultiPolygon(geoJson);
    }
}

