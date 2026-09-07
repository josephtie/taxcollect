package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.SecteurDto;

import java.util.List;
import java.util.Optional;

public interface SecteurService {
    SecteurDto create(SecteurDto secteurDto);
    SecteurDto update(Long id, SecteurDto secteurDto);
    Optional<SecteurDto> findById(Long id);
    List<SecteurDto> findAll();
    void delete(Long id);
    void restore(Long id);
    List<SecteurDto> findAllIncludingDeleted();
    Optional<SecteurDto> locateByGps(double latitude, double longitude);
}
