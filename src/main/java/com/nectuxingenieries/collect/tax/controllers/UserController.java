package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.dto.CreateUserRequest;
import com.nectuxingenieries.collect.tax.dto.ResetPasswordRequest;
import com.nectuxingenieries.collect.tax.dto.UserWithRolesDto;
import com.nectuxingenieries.collect.tax.services.KeycloakUserService;
import lombok.RequiredArgsConstructor;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

   @Autowired
   private  KeycloakUserService keycloakUserService;


    //@PreAuthorize("hasRole('ADMIN')")
    //@All
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

    @GetMapping("/{userId}")
    public ResponseEntity<UserWithRolesDto> getUserById(@PathVariable String userId) {
        UserWithRolesDto user = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}")
    public ResponseEntity<UserWithRolesDto> updateUser(@PathVariable String userId, @RequestBody CreateUserRequest request) {
        keycloakUserService.updateUser(userId, request);
        UserWithRolesDto updatedUser = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(updatedUser);
    }

    @PutMapping("/{userId}/status")
    public ResponseEntity<UserWithRolesDto> toggleUserStatus(@PathVariable String userId, @RequestParam boolean active) {
        keycloakUserService.toggleUserStatus(userId, active);
        UserWithRolesDto updatedUser = keycloakUserService.getUserById(userId);
        return ResponseEntity.ok(updatedUser);
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
    public ResponseEntity<List<UserWithRolesDto>> listUsers() {
        return ResponseEntity.ok(keycloakUserService.getAllUsersWithRolesAndLastLogin());
    }
}

