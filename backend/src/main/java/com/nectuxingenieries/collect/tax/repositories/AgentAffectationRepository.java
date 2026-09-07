package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.AgentAffectation;
import com.nectuxingenieries.collect.tax.models.TerritoryType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgentAffectationRepository extends JpaRepository<AgentAffectation, Long> {

    @Query("SELECT a FROM AgentAffectation a WHERE a.territoryType = :type AND a.territoryId = :territoryId AND a.statut = TRUE AND a.deletedAt IS NULL")
    List<AgentAffectation> findActiveByTerritory(@Param("type") TerritoryType type, @Param("territoryId") Long territoryId);

    @Query("SELECT a FROM AgentAffectation a WHERE a.agent.id = :agentId AND a.statut = TRUE AND a.deletedAt IS NULL")
    List<AgentAffectation> findActiveByAgent(@Param("agentId") Long agentId);

    @Query("SELECT a FROM AgentAffectation a WHERE a.agent.id = :agentId AND a.territoryType = :type AND a.territoryId = :territoryId AND a.statut = TRUE AND a.deletedAt IS NULL")
    Optional<AgentAffectation> findActiveAssignment(@Param("agentId") Long agentId, @Param("type") TerritoryType type, @Param("territoryId") Long territoryId);

    @Query("SELECT a FROM AgentAffectation a WHERE a.agent.id = :agentId AND a.territoryType = :type AND a.territoryId = :territoryId AND a.deletedAt IS NULL")
    Optional<AgentAffectation> findAnyAssignment(@Param("agentId") Long agentId, @Param("type") TerritoryType type, @Param("territoryId") Long territoryId);
}
