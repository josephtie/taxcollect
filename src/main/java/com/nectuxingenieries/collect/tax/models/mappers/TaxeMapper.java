package com.nectuxingenieries.collect.tax.models.mappers;


import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.models.dto.TaxeDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface TaxeMapper {

    TaxeDto toDto(Taxe taxe);
    Taxe toEntity(TaxeDto taxeDto);
    void updateFromDto(TaxeDto taxeDto, @MappingTarget Taxe taxe);
}

