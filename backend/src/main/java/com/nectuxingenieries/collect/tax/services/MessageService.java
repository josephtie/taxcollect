package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.MessageDto;
import java.util.List;
import java.util.Optional;

public interface MessageService {
    MessageDto create(MessageDto messageDto);
    Optional<MessageDto> findById(Long id);
    List<MessageDto> findConversation(Long userId);
    List<MessageDto> findBySignalementId(Long signalementId);
    List<MessageDto> findUnreadByDestinataire(Long userId);
    long countUnreadByDestinataire(Long userId);
    void markAsRead(Long id);
    void delete(Long id);
}
