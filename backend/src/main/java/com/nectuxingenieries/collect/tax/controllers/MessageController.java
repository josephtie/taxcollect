package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.MessageDto;
import com.nectuxingenieries.collect.tax.services.MessageService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/messagerie")
@RequiredArgsConstructor
@Tag(name = "Messagerie", description = "API de messagerie agent ↔ superviseur")
public class MessageController {

    private final MessageService messageService;

    @GetMapping("/conversation/{userId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<MessageDto>> findConversation(@PathVariable Long userId) {
        return ResponseEntity.ok(messageService.findConversation(userId));
    }

    @GetMapping("/signalement/{signalementId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<MessageDto>> findBySignalement(@PathVariable Long signalementId) {
        return ResponseEntity.ok(messageService.findBySignalementId(signalementId));
    }

    @GetMapping("/unread/{userId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<MessageDto>> findUnread(@PathVariable Long userId) {
        return ResponseEntity.ok(messageService.findUnreadByDestinataire(userId));
    }

    @GetMapping("/unread/{userId}/count")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Long> countUnread(@PathVariable Long userId) {
        return ResponseEntity.ok(messageService.countUnreadByDestinataire(userId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<MessageDto> create(@RequestBody MessageDto messageDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(messageService.create(messageDto));
    }

    @PostMapping("/{id}/read")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        messageService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        messageService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
