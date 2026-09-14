package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.TourneeDto;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TourneeService {
    TourneeDto create(TourneeDto tourneeDto);
    TourneeDto update(Long id, TourneeDto tourneeDto);
    Optional<TourneeDto> findById(Long id);
    List<TourneeDto> findAll();
    List<TourneeDto> findByAgentId(Long agentId);
    List<TourneeDto> findByDate(LocalDate date);
    void delete(Long id);
    void restore(Long id);
    TourneeDto demarrerTournee(Long id);
    TourneeDto terminerTournee(Long id);
}
