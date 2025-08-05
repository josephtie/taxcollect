package com.nectuxingenieries.collect.tax.models.mappers;


import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.models.dto.TaxeCollectDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface TaxeCollectMapper {

    TaxeCollectDto toDto(TaxeCollect paiement);
    TaxeCollect toEntity(TaxeCollectDto paiementDto);
    void updateFromDto(TaxeCollectDto paiementDto, @MappingTarget TaxeCollect paiement);
}

