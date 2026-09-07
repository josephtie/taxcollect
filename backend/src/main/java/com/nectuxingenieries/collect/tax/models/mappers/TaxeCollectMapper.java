package com.nectuxingenieries.collect.tax.models.mappers;


import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface TaxeCollectMapper {

    @Mapping(source = "contribuable.id", target = "contribuableId")
    @Mapping(source = "taxe.id", target = "taxeId")
    TaxeCollectDto toDto(TaxeCollect paiement);

    @Mapping(target = "contribuable", ignore = true)
    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "taxe", ignore = true)
    TaxeCollect toEntity(TaxeCollectDto paiementDto);

    @Mapping(target = "contribuable", ignore = true)
    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "taxe", ignore = true)
    void updateFromDto(TaxeCollectDto paiementDto, @MappingTarget TaxeCollect paiement);
}

