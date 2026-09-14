package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Message;
import com.nectuxingenieries.collect.tax.dto.MessageDto;
import com.nectuxingenieries.collect.tax.models.mappers.MessageMapper;
import com.nectuxingenieries.collect.tax.services.MessageService;
import com.nectuxingenieries.collect.tax.repositories.MessageRepository;
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
public class MessageServiceImpl implements MessageService {

    @Autowired
    private MessageRepository messageRepository;
    @Autowired
    private MessageMapper messageMapper;

    @Override
    public MessageDto create(MessageDto messageDto) {
        Message entity = messageMapper.toEntity(messageDto);
        return messageMapper.toDto(messageRepository.save(entity));
    }

    @Override
    public Optional<MessageDto> findById(Long id) {
        return messageRepository.findById(id).map(messageMapper::toDto);
    }

    @Override
    public List<MessageDto> findConversation(Long userId) {
        return messageRepository.findConversation(userId).stream()
                .map(messageMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<MessageDto> findBySignalementId(Long signalementId) {
        return messageRepository.findBySignalementId(signalementId).stream()
                .map(messageMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<MessageDto> findUnreadByDestinataire(Long userId) {
        return messageRepository.findUnreadByDestinataire(userId).stream()
                .map(messageMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public long countUnreadByDestinataire(Long userId) {
        return messageRepository.countUnreadByDestinataire(userId);
    }

    @Override
    public void markAsRead(Long id) {
        Message message = messageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Message non trouvé"));
        message.setLu(true);
        message.setDateLecture(LocalDateTime.now());
        messageRepository.save(message);
    }

    @Override
    public void delete(Long id) {
        messageRepository.deleteLogical(id, "system");
    }
}
