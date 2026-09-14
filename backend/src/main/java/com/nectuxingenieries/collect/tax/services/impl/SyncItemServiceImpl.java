package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.SyncItem;
import com.nectuxingenieries.collect.tax.dto.SyncItemDto;
import com.nectuxingenieries.collect.tax.models.mappers.SyncItemMapper;
import com.nectuxingenieries.collect.tax.services.SyncItemService;
import com.nectuxingenieries.collect.tax.repositories.SyncItemRepository;
import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class SyncItemServiceImpl implements SyncItemService {

    @Autowired
    private SyncItemRepository syncItemRepository;
    @Autowired
    private SyncItemMapper syncItemMapper;

    @Override
    public SyncItemDto create(SyncItemDto syncItemDto) {
        SyncItem entity = syncItemMapper.toEntity(syncItemDto);
        return syncItemMapper.toDto(syncItemRepository.save(entity));
    }

    @Override
    public Optional<SyncItemDto> findById(Long id) {
        return syncItemRepository.findById(id).map(syncItemMapper::toDto);
    }

    @Override
    public List<SyncItemDto> findByAgentId(Long agentId) {
        return syncItemRepository.findByAgentId(agentId).stream()
                .map(syncItemMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<SyncItemDto> findByAgentIdAndStatut(Long agentId, StatutSyncItem statut) {
        return syncItemRepository.findByAgentIdAndStatut(agentId, statut).stream()
                .map(syncItemMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<SyncItemDto> findByStatut(StatutSyncItem statut) {
        return syncItemRepository.findByStatut(statut).stream()
                .map(syncItemMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void markSynced(Long id) {
        syncItemRepository.updateStatut(id, StatutSyncItem.SYNCED, LocalDateTime.now());
    }

    @Override
    public void markFailed(Long id, String errorMessage) {
        syncItemRepository.markFailed(id, StatutSyncItem.FAILED, errorMessage, LocalDateTime.now());
    }

    @Override
    public long countPendingByAgentId(Long agentId) {
        return syncItemRepository.countByAgentIdAndStatut(agentId, StatutSyncItem.PENDING);
    }

    @Override
    public void delete(Long id) {
        syncItemRepository.deleteLogical(id, "system");
    }
}
