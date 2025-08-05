package com.nectuxingenieries.collect.tax.controllers;


import com.nectuxingenieries.collect.tax.models.dto.LdapUserRequest;
import com.nectuxingenieries.collect.tax.models.dto.ResetPasswordRequest;
import com.nectuxingenieries.collect.tax.services.LdapUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Base64;

@Slf4j
@RestController
@RequestMapping("/api/ldap/users")
@RequiredArgsConstructor
public class LdapUserController {

    private final LdapUserService ldapUserService;



    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<?> createLdapUser(@RequestBody LdapUserRequest request) {
        ldapUserService.createUser(
                request.getMatricule(),
                request.getFirstName(),
                request.getLastName(),
                request.getEmail(),
                request.getPassword(),
                request.getRoles()
        );
        return ResponseEntity.ok("✅ Utilisateur LDAP créé avec succès.");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{matricule}")
    public ResponseEntity<?> deleteLdapUser(@PathVariable String matricule) {
        ldapUserService.deleteUserByMatricule(matricule);
        return ResponseEntity.ok("🗑️ Utilisateur LDAP supprimé.");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/exists/{matricule}")
    public ResponseEntity<Boolean> checkUserExists(@PathVariable String matricule) {
        boolean exists = ldapUserService.userExists(matricule);
        return ResponseEntity.ok(exists);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        ldapUserService.resetPassword(request.getMatricule(), request.getNewPassword());
        return ResponseEntity.ok("🔑 Mot de passe réinitialisé.");
    }

    @PutMapping("/{matricule}")
    public ResponseEntity<?> updateUser(
            @PathVariable String matricule,
            @RequestParam String firstName,
            @RequestParam String lastName,
            @RequestParam String email
    ) {
        ldapUserService.updateUser(matricule, firstName, lastName, email);
        return ResponseEntity.ok("✅ Utilisateur mis à jour");
    }

    @PostMapping("/{matricule}/groups/{groupName}")
    public ResponseEntity<?> assignUserToGroup(
            @PathVariable String matricule,
            @PathVariable String groupName
    ) {
        ldapUserService.assignUserToGroup(matricule, groupName);
        return ResponseEntity.ok("✅ Utilisateur ajouté au groupe");
    }

    @DeleteMapping("/{matricule}/groups/{groupName}")
    public ResponseEntity<?> removeUserFromGroup(
            @PathVariable String matricule,
            @PathVariable String groupName
    ) {
        ldapUserService.removeUserFromGroup(matricule, groupName);
        return ResponseEntity.ok("🧹 Utilisateur retiré du groupe");
    }

    @DeleteMapping("/groups/{groupName}/members")
    public ResponseEntity<?> clearGroup(@PathVariable String groupName) {
        ldapUserService.removeAllUsersFromGroup(groupName);
        return ResponseEntity.ok("🧼 Groupe vidé");
    }


}

