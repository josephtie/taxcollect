package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.TerritoryType;
import java.util.List;

public class EffectivePerimeterDto {
    private Long agentId;
    private String agentNom;
    private String agentPrenom;
    private List<TerritoryRef> territories;

    public static class TerritoryRef {
        private TerritoryType type;
        private Long id;
        private String nom;

        public TerritoryType getType() { return type; }
        public void setType(TerritoryType type) { this.type = type; }
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
    }

    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public String getAgentPrenom() { return agentPrenom; }
    public void setAgentPrenom(String agentPrenom) { this.agentPrenom = agentPrenom; }
    public List<TerritoryRef> getTerritories() { return territories; }
    public void setTerritories(List<TerritoryRef> territories) { this.territories = territories; }
}
