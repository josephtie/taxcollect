package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Portefeuille;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PortefeuilleRepository extends BaseRepository<Portefeuille, Long>, JpaSpecificationExecutor<Portefeuille> {

    @Query("SELECT p FROM Portefeuille p WHERE p.agent.id = :agentId AND p.statut = true AND p.deletedAt IS NULL")
    List<Portefeuille> findActiveByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT p FROM Portefeuille p WHERE p.contribuable.id = :contribuableId AND p.statut = true AND p.deletedAt IS NULL")
    List<Portefeuille> findActiveByContribuableId(@Param("contribuableId") Long contribuableId);

    @Query("SELECT p FROM Portefeuille p WHERE p.agent.id = :agentId AND p.contribuable.id = :contribuableId AND p.deletedAt IS NULL")
    Optional<Portefeuille> findByAgentAndContribuable(@Param("agentId") Long agentId, @Param("contribuableId") Long contribuableId);
}
