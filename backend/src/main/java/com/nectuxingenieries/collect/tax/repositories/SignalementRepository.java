package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Signalement;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SignalementRepository extends BaseRepository<Signalement, Long>, JpaSpecificationExecutor<Signalement> {

    @Query("SELECT s FROM Signalement s WHERE s.agentId = :agentId AND s.deletedAt IS NULL ORDER BY s.createdAt DESC")
    List<Signalement> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT s FROM Signalement s WHERE s.statut = :statut AND s.deletedAt IS NULL ORDER BY s.createdAt DESC")
    List<Signalement> findByStatut(@Param("statut") String statut);

    @Query("SELECT s FROM Signalement s WHERE s.contribuableId = :contribuableId AND s.deletedAt IS NULL ORDER BY s.createdAt DESC")
    List<Signalement> findByContribuableId(@Param("contribuableId") Long contribuableId);
}
