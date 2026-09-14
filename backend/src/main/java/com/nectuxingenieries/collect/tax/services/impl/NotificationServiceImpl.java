package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Notification;
import com.nectuxingenieries.collect.tax.dto.NotificationDto;
import com.nectuxingenieries.collect.tax.models.mappers.NotificationMapper;
import com.nectuxingenieries.collect.tax.services.NotificationService;
import com.nectuxingenieries.collect.tax.repositories.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;
    @Autowired
    private NotificationMapper notificationMapper;

    @Override
    public NotificationDto create(NotificationDto notificationDto) {
        Notification entity = notificationMapper.toEntity(notificationDto);
        return notificationMapper.toDto(notificationRepository.save(entity));
    }

    @Override
    public Optional<NotificationDto> findById(Long id) {
        return notificationRepository.findById(id).map(notificationMapper::toDto);
    }

    @Override
    public List<NotificationDto> findByAgentId(Long agentId) {
        return notificationRepository.findByAgentId(agentId).stream()
                .map(notificationMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<NotificationDto> findUnreadByAgentId(Long agentId) {
        return notificationRepository.findUnreadByAgentId(agentId).stream()
                .map(notificationMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public long countUnreadByAgentId(Long agentId) {
        return notificationRepository.countUnreadByAgentId(agentId);
    }

    @Override
    public void markAsRead(Long id) {
        notificationRepository.markAsRead(id);
    }

    @Override
    public void markAllAsRead(Long agentId) {
        notificationRepository.markAllAsRead(agentId);
    }

    @Override
    public void delete(Long id) {
        notificationRepository.deleteLogical(id, "system");
    }
}
