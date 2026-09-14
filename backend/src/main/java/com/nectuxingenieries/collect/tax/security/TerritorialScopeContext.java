package com.nectuxingenieries.collect.tax.security;

import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.RequestScope;

@Component
@RequestScope
public class TerritorialScopeContext {

    private Long zoneId;
    private Long quartierId;
    private Long secteurId;
    private String userId;
    private String userRole;

    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }

    public Long getQuartierId() { return quartierId; }
    public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }

    public Long getSecteurId() { return secteurId; }
    public void setSecteurId(Long secteurId) { this.secteurId = secteurId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public boolean hasZoneScope() { return zoneId != null; }
    public boolean hasQuartierScope() { return quartierId != null; }
    public boolean hasSecteurScope() { return secteurId != null; }

    public boolean isAdmin() { return "ADMIN".equals(userRole); }

    public boolean canAccessZone(Long requestedZoneId) {
        return isAdmin() || zoneId == null || zoneId.equals(requestedZoneId);
    }

    public boolean canAccessQuartier(Long requestedQuartierId) {
        return isAdmin() || quartierId == null || quartierId.equals(requestedQuartierId);
    }

    public boolean canAccessSecteur(Long requestedSecteurId) {
        return isAdmin() || secteurId == null || secteurId.equals(requestedSecteurId);
    }
}
