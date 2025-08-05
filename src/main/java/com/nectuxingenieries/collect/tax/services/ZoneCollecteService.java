package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.ZoneCollectDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface ZoneCollecteService {
    ZoneCollectDto create(ZoneCollectDto zoneCollecteDto);
    ZoneCollectDto update(Long id, ZoneCollectDto zoneCollecteDto);
    ZoneCollectDto findById(Long id);
    List<ZoneCollectDto> findAll();
    Page<ZoneCollectDto> findAll(Pageable pageable);

    Page<ZoneCollectDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}
