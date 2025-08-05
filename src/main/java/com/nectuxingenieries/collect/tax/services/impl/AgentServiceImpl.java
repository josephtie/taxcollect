package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dao.AgentsRepository;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.dto.AgentsDto;
import com.nectuxingenieries.collect.tax.models.mappers.AgentsMapper;
import com.nectuxingenieries.collect.tax.services.AgentService;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;


@Service
@Transactional
@RequiredArgsConstructor
public class AgentServiceImpl implements AgentService {

   @Autowired
   private  AgentsRepository  agentRepository;
    @Autowired
    private  AgentsMapper agentMapper;



    @Override
    public AgentsDto create(AgentsDto agentsDto) {
        Agents entity = agentMapper.toEntity(agentsDto);
        return agentMapper.toDto(agentRepository.save(entity));
    }
    @Override
    public AgentsDto update(Long id, AgentsDto AgentsDto) {
        Agents existing = agentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
        agentMapper.updateFromDto(AgentsDto, existing);
        return agentMapper.toDto(agentRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public AgentsDto findById(Long id) {
        return agentRepository.findById(id)
                .map(agentMapper::toDto)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<AgentsDto> findAll() {
        return agentRepository.findAll()
                .stream()
                .map(agentMapper::toDto)
                .toList();
    }

    @Override
    public Page<AgentsDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Agents> specification = GenericSpecifications.fromMap(filters);
        return agentRepository.findAll(specification, pageable).map(agentMapper::toDto);
    }


    @Override
    @Transactional(readOnly = true)
    public Page<AgentsDto> findAll(Pageable pageable) {
        return agentRepository.findAll(pageable).map(agentMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        agentRepository.deleteById(id);
    }
}
