package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.NotificationDto;
import java.util.List;
import java.util.Optional;

public interface NotificationService {
    NotificationDto create(NotificationDto notificationDto);
    Optional<NotificationDto> findById(Long id);
    List<NotificationDto> findByAgentId(Long agentId);
    List<NotificationDto> findUnreadByAgentId(Long agentId);
    long countUnreadByAgentId(Long agentId);
    void markAsRead(Long id);
    void markAllAsRead(Long agentId);
    void delete(Long id);
}
