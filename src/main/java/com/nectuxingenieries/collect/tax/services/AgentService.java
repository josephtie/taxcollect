package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.dto.AgentsDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

public interface AgentService {
    AgentsDto create(AgentsDto agentDto);
    AgentsDto update(Long id, AgentsDto agentDto);
    AgentsDto findById(Long id);
    List<AgentsDto> findAll();
    Page<AgentsDto> findAll(Pageable pageable);
    Page<AgentsDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
}

