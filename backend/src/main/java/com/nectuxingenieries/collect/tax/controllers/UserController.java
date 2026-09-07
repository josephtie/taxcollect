package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.dto.CreateUserRequest;
import com.nectuxingenieries.collect.tax.dto.ResetPasswordRequest;
import com.nectuxingenieries.collect.tax.dto.UserWithRolesDto;
import com.nectuxingenieries.collect.tax.services.KeycloakUserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "Utilisateurs", description = "API de gestion des utilisateurs Keycloak")
public class UserController {

   @Autowired
   private  KeycloakUserService keycloakUserService;


    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<String> createUser(@RequestBody CreateUserRequest request) {
        String userId = keycloakUserService.registerUser(
                request.getUsername(),
                request.getEmail(),
                request.getFirstName(),
                request.getLastName(),
                request.getPassword(),
                request.getRoles()
        );
        return ResponseEntity.ok(userId);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{userId}")
    public ResponseEntity<UserWithRolesDto> getUserById(@PathVariable String userId) {
        UserWithRolesDto user = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(user);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{userId}")
    public ResponseEntity<UserWithRolesDto> updateUser(@PathVariable String userId, @RequestBody CreateUserRequest request) {
        keycloakUserService.updateUser(userId, request);
        UserWithRolesDto updatedUser = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(updatedUser);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{userId}/status")
    public ResponseEntity<UserWithRolesDto> toggleUserStatus(@PathVariable String userId, @RequestParam boolean active) {
        keycloakUserService.toggleUserStatus(userId, active);
        UserWithRolesDto updatedUser = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(updatedUser);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{userId}/reset-password")
    public ResponseEntity<Void> resetPassword(@PathVariable String userId, @RequestBody ResetPasswordRequest request) {
        keycloakUserService.requestPasswordReset(userId, request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteUser(@PathVariable String userId) {
        keycloakUserService.deleteUser(userId);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<UserWithRolesDto>> listUsers() {
        List<UserWithRolesDto> users = keycloakUserService.getAllUsersWithRolesAndLastLogin();
        Map<String, Integer> sessionCounts = keycloakUserService.getAllUserSessionCounts();
        users.forEach(u -> u.getUserdto().setSessionCount(sessionCounts.getOrDefault(u.getUserdto().getId(), 0)));
        return ResponseEntity.ok(users);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{userId}/sessions")
    public ResponseEntity<List<Map<String, Object>>> getUserSessions(@PathVariable String userId) {
        return ResponseEntity.ok(keycloakUserService.getUserSessions(userId));
    }
}

