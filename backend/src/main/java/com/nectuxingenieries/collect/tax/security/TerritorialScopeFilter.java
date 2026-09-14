package com.nectuxingenieries.collect.tax.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collection;
import java.util.Map;

@Component
public class TerritorialScopeFilter extends OncePerRequestFilter {

    private final TerritorialScopeContext scopeContext;

    public TerritorialScopeFilter(TerritorialScopeContext scopeContext) {
        this.scopeContext = scopeContext;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                     HttpServletResponse response,
                                     FilterChain filterChain) throws ServletException, IOException {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            Jwt jwt = jwtAuth.getToken();

            scopeContext.setUserId(jwt.getClaim("sub"));

            Object zoneIdClaim = jwt.getClaim("zone_id");
            if (zoneIdClaim instanceof Number) {
                scopeContext.setZoneId(((Number) zoneIdClaim).longValue());
            } else if (zoneIdClaim instanceof String) {
                try { scopeContext.setZoneId(Long.parseLong((String) zoneIdClaim)); } catch (NumberFormatException ignored) {}
            }

            Object quartierIdClaim = jwt.getClaim("quartier_id");
            if (quartierIdClaim instanceof Number) {
                scopeContext.setQuartierId(((Number) quartierIdClaim).longValue());
            } else if (quartierIdClaim instanceof String) {
                try { scopeContext.setQuartierId(Long.parseLong((String) quartierIdClaim)); } catch (NumberFormatException ignored) {}
            }

            Object secteurIdClaim = jwt.getClaim("secteur_id");
            if (secteurIdClaim instanceof Number) {
                scopeContext.setSecteurId(((Number) secteurIdClaim).longValue());
            } else if (secteurIdClaim instanceof String) {
                try { scopeContext.setSecteurId(Long.parseLong((String) secteurIdClaim)); } catch (NumberFormatException ignored) {}
            }

            Collection<? extends org.springframework.security.core.GrantedAuthority> authorities = jwtAuth.getAuthorities();
            String role = authorities.stream()
                    .map(a -> a.getAuthority().replace("ROLE_", ""))
                    .filter(r -> r.equals("ADMIN") || r.equals("SUPERVISEUR") || r.equals("RESPONSABLE_QUARTIER") || r.equals("AGENT") || r.equals("TRESOR"))
                    .findFirst()
                    .orElse("AGENT");
            scopeContext.setUserRole(role);
        }

        filterChain.doFilter(request, response);
    }
}
