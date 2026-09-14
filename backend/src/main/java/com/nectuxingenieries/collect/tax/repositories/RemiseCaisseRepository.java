package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.RemiseCaisse;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RemiseCaisseRepository extends BaseRepository<RemiseCaisse, Long>, JpaSpecificationExecutor<RemiseCaisse> {

    @Query("SELECT r FROM RemiseCaisse r WHERE r.caisse.id = :caisseId AND r.deletedAt IS NULL ORDER BY r.dateRemise DESC")
    List<RemiseCaisse> findByCaisseId(@Param("caisseId") Long caisseId);

    @Query("SELECT r FROM RemiseCaisse r WHERE r.statut = :statut AND r.deletedAt IS NULL ORDER BY r.dateRemise DESC")
    List<RemiseCaisse> findByStatut(@Param("statut") String statut);

    @Query("SELECT r FROM RemiseCaisse r WHERE r.caisse.agent.id = :agentId AND r.deletedAt IS NULL ORDER BY r.dateRemise DESC")
    List<RemiseCaisse> findByAgentId(@Param("agentId") Long agentId);
}
