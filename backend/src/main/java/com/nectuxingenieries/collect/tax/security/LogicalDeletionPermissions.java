package com.nectuxingenieries.collect.tax.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

/**
 * Gestionnaire de permissions pour la suppression logique
 */
@Component
public class LogicalDeletionPermissions {

    // Rôles autorisés à restaurer des entités
    private static final List<String> RESTORE_ROLES = Arrays.asList(
        "ADMIN",
        "SUPERVISEUR",
        "MANAGER"
    );

    /**
     * Vérifie si l'utilisateur actuel peut restaurer une entité
     * @param deletedBy - L'utilisateur qui a supprimé l'entité
     * @return true si l'utilisateur peut restaurer
     */
    public boolean canRestore(String deletedBy) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        String currentUser = auth.getName();
        String userRole = auth.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .filter(authority -> authority.startsWith("ROLE_"))
                .map(authority -> authority.substring(5)) // Remove "ROLE_" prefix
                .findFirst()
                .orElse("USER");

        // L'utilisateur peut restaurer si :
        // 1. Il a un rôle autorisé
        // 2. OU il est celui qui a supprimé l'entité
        return RESTORE_ROLES.contains(userRole) || 
               currentUser.equals(deletedBy);
    }

    /**
     * Vérifie si l'utilisateur actuel peut supprimer une entité
     * @return true si l'utilisateur peut supprimer
     */
    public boolean canDelete() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        // Tous les utilisateurs authentifiés peuvent supprimer
        // (sauf les utilisateurs avec le rôle READ_ONLY)
        return auth.getAuthorities().stream()
                .noneMatch(authority -> 
                    authority.getAuthority().equals("ROLE_READ_ONLY"));
    }

    /**
     * Vérifie si l'utilisateur actuel peut voir les entités supprimées
     * @return true si l'utilisateur peut voir les entités supprimées
     */
    public boolean canViewDeleted() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        String userRole = auth.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .filter(authority -> authority.startsWith("ROLE_"))
                .map(authority -> authority.substring(5))
                .findFirst()
                .orElse("USER");

        // Seuls les rôles autorisés peuvent voir les entités supprimées
        return RESTORE_ROLES.contains(userRole);
    }

    /**
     * Obtient l'utilisateur actuel
     * @return le nom de l'utilisateur actuel
     */
    public String getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            return "system";
        }

        return auth.getName();
    }

    /**
     * Vérifie si l'utilisateur a un rôle spécifique
     * @param role - Le rôle à vérifier
     * @return true si l'utilisateur a le rôle
     */
    public boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        return auth.getAuthorities().stream()
                .anyMatch(authority -> 
                    authority.getAuthority().equals("ROLE_" + role));
    }
}
