package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Tournee;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.dto.TourneeDto;
import com.nectuxingenieries.collect.tax.models.mappers.TourneeMapper;
import com.nectuxingenieries.collect.tax.services.TourneeService;
import com.nectuxingenieries.collect.tax.repositories.TourneeRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class TourneeServiceImpl implements TourneeService {

    @Autowired
    private TourneeRepository tourneeRepository;
    @Autowired
    private TourneeMapper tourneeMapper;
    @Autowired
    private AgentRepository agentRepository;

    @Override
    public TourneeDto create(TourneeDto tourneeDto) {
        Tournee entity = tourneeMapper.toEntity(tourneeDto);
        if (tourneeDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(tourneeDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            entity.setAgent(agent);
        }
        return tourneeMapper.toDto(tourneeRepository.save(entity));
    }

    @Override
    public TourneeDto update(Long id, TourneeDto tourneeDto) {
        Tournee existing = tourneeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));
        tourneeMapper.updateFromDto(tourneeDto, existing);
        if (tourneeDto.getAgentId() != null) {
            Agents agent = agentRepository.findById(tourneeDto.getAgentId())
                    .orElseThrow(() -> new RuntimeException("Agent non trouvé"));
            existing.setAgent(agent);
        }
        return tourneeMapper.toDto(tourneeRepository.save(existing));
    }

    @Override
    public Optional<TourneeDto> findById(Long id) {
        return tourneeRepository.findById(id).map(tourneeMapper::toDto);
    }

    @Override
    public List<TourneeDto> findAll() {
        return tourneeRepository.findAll().stream()
                .map(tourneeMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<TourneeDto> findByAgentId(Long agentId) {
        return tourneeRepository.findByAgentId(agentId).stream()
                .map(tourneeMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<TourneeDto> findByDate(LocalDate date) {
        return tourneeRepository.findByDate(date).stream()
                .map(tourneeMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Long id) {
        tourneeRepository.deleteLogical(id, "system");
    }

    @Override
    public void restore(Long id) {
        tourneeRepository.restore(id);
    }

    @Override
    public TourneeDto demarrerTournee(Long id) {
        Tournee tournee = tourneeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));
        tournee.setStatut(com.nectuxingenieries.collect.tax.models.enums.StatutTournee.EN_COURS);
        return tourneeMapper.toDto(tourneeRepository.save(tournee));
    }

    @Override
    public TourneeDto terminerTournee(Long id) {
        Tournee tournee = tourneeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tournée non trouvée"));
        tournee.setStatut(com.nectuxingenieries.collect.tax.models.enums.StatutTournee.TERMINEE);
        return tourneeMapper.toDto(tourneeRepository.save(tournee));
    }
}
