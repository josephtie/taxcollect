package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Anomalie;
import com.nectuxingenieries.collect.tax.models.enums.StatutAnomalie;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnomalieRepository extends BaseRepository<Anomalie, Long>, JpaSpecificationExecutor<Anomalie> {

    @Query("SELECT a FROM Anomalie a WHERE a.quartierId = :quartierId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<Anomalie> findByQuartierId(@Param("quartierId") Long quartierId);

    @Query("SELECT a FROM Anomalie a WHERE a.quartierId = :quartierId AND a.statut = :statut AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<Anomalie> findByQuartierIdAndStatut(@Param("quartierId") Long quartierId, @Param("statut") StatutAnomalie statut);

    @Query("SELECT a FROM Anomalie a WHERE a.statut = :statut AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<Anomalie> findByStatut(@Param("statut") StatutAnomalie statut);

    @Query("SELECT a FROM Anomalie a WHERE a.agentId = :agentId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<Anomalie> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT COUNT(a) FROM Anomalie a WHERE a.quartierId = :quartierId AND a.statut != 'CLOTUREE' AND a.deletedAt IS NULL")
    long countOpenByQuartierId(@Param("quartierId") Long quartierId);
}
