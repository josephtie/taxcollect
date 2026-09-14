package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Caisse;
import com.nectuxingenieries.collect.tax.models.enums.StatutCaisse;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CaisseRepository extends BaseRepository<Caisse, Long>, JpaSpecificationExecutor<Caisse> {

    @Query("SELECT c FROM Caisse c WHERE c.agent.id = :agentId AND c.dateCaisse = :date AND c.deletedAt IS NULL")
    Optional<Caisse> findByAgentAndDate(@Param("agentId") Long agentId, @Param("date") LocalDate date);

    @Query("SELECT c FROM Caisse c WHERE c.agent.id = :agentId AND c.deletedAt IS NULL ORDER BY c.dateCaisse DESC")
    List<Caisse> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT c FROM Caisse c WHERE c.agent.id = :agentId AND c.statut = :statut AND c.deletedAt IS NULL")
    List<Caisse> findByAgentIdAndStatut(@Param("agentId") Long agentId, @Param("statut") StatutCaisse statut);

    @Query("SELECT c FROM Caisse c WHERE c.statut = :statut AND c.deletedAt IS NULL")
    List<Caisse> findByStatut(@Param("statut") StatutCaisse statut);
}
