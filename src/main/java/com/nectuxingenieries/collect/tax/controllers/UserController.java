package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.models.dto.CreateUserRequest;
import com.nectuxingenieries.collect.tax.models.dto.ResetPasswordRequest;
import com.nectuxingenieries.collect.tax.models.dto.UserRepresentationDTO;
import com.nectuxingenieries.collect.tax.services.KeycloakUserService;
import lombok.RequiredArgsConstructor;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
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

    @PutMapping("/{userId}/reset-password")
    public ResponseEntity<Void> resetPassword(@PathVariable String userId, @RequestBody ResetPasswordRequest request) {
        keycloakUserService.requestPasswordReset(userId, request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteUser(@PathVariable String userId) {
        keycloakUserService.deleteUser(userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<UserRepresentation>> listUsers() {
        return ResponseEntity.ok(keycloakUserService.getAllUsers());
    }
}

