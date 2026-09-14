package com.nectuxingenieries.collect.tax.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SecurityScopeService {

    public String getCurrentUserId() {
        JwtAuthenticationToken auth = getJwtAuthentication();
        if (auth == null) return null;
        return auth.getToken().getClaimAsString("preferred_username");
    }

    public String getCurrentRole() {
        JwtAuthenticationToken auth = getJwtAuthentication();
        if (auth == null) return null;
        Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
        for (GrantedAuthority ga : authorities) {
            String role = ga.getAuthority().replace("ROLE_", "");
            switch (role) {
                case "ADMIN":
                case "SUPERVISEUR":
                case "RESPONSABLE_QUARTIER":
                case "TRESOR":
                case "AGENT":
                    return role;
            }
        }
        return null;
    }

    public boolean isAdmin() {
        return "ADMIN".equals(getCurrentRole());
    }

    public boolean isSuperviseur() {
        return "SUPERVISEUR".equals(getCurrentRole());
    }

    public boolean isResponsableQuartier() {
        return "RESPONSABLE_QUARTIER".equals(getCurrentRole());
    }

    public boolean isTresor() {
        return "TRESOR".equals(getCurrentRole());
    }

    public boolean isAgent() {
        return "AGENT".equals(getCurrentRole());
    }

    public boolean canViewAllZones() {
        return isAdmin() || isSuperviseur();
    }

    public boolean canViewAllQuartiers() {
        return isAdmin() || isSuperviseur() || isResponsableQuartier();
    }

    public boolean canViewAllSecteurs() {
        return isAdmin() || isSuperviseur() || isResponsableQuartier();
    }

    public List<String> getCurrentRoles() {
        JwtAuthenticationToken auth = getJwtAuthentication();
        if (auth == null) return List.of();
        return auth.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .map(a -> a.replace("ROLE_", ""))
                .collect(Collectors.toList());
    }

    private JwtAuthenticationToken getJwtAuthentication() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof JwtAuthenticationToken jwtAuth) {
            return jwtAuth;
        }
        return null;
    }
}
