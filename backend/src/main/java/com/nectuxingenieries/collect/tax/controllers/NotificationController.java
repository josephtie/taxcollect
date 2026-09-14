package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.NotificationDto;
import com.nectuxingenieries.collect.tax.services.NotificationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/taxcollect/notification")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "API de gestion des notifications agent")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/agent/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<NotificationDto>> findByAgent(@PathVariable Long agentId) {
        return ResponseEntity.ok(notificationService.findByAgentId(agentId));
    }

    @GetMapping("/agent/{agentId}/unread")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<List<NotificationDto>> findUnread(@PathVariable Long agentId) {
        return ResponseEntity.ok(notificationService.findUnreadByAgentId(agentId));
    }

    @GetMapping("/agent/{agentId}/unread/count")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Long> countUnread(@PathVariable Long agentId) {
        return ResponseEntity.ok(notificationService.countUnreadByAgentId(agentId));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<NotificationDto> findById(@PathVariable Long id) {
        return notificationService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<NotificationDto> create(@RequestBody NotificationDto notificationDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(notificationService.create(notificationDto));
    }

    @PostMapping("/{id}/read")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/agent/{agentId}/read-all")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<Void> markAllAsRead(@PathVariable Long agentId) {
        notificationService.markAllAsRead(agentId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        notificationService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
