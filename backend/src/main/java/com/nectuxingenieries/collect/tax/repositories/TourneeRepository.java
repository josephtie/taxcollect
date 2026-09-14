package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Tournee;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface TourneeRepository extends BaseRepository<Tournee, Long>, JpaSpecificationExecutor<Tournee> {

    @Query("SELECT t FROM Tournee t WHERE t.agent.id = :agentId AND t.dateTournee = :date AND t.deletedAt IS NULL")
    Optional<Tournee> findByAgentAndDate(@Param("agentId") Long agentId, @Param("date") LocalDate date);

    @Query("SELECT t FROM Tournee t WHERE t.agent.id = :agentId AND t.deletedAt IS NULL ORDER BY t.dateTournee DESC")
    List<Tournee> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT t FROM Tournee t WHERE t.dateTournee = :date AND t.deletedAt IS NULL")
    List<Tournee> findByDate(@Param("date") LocalDate date);

    @Query("SELECT t FROM Tournee t WHERE t.statut = :statut AND t.deletedAt IS NULL")
    List<Tournee> findByStatut(@Param("statut") com.nectuxingenieries.collect.tax.models.enums.StatutTournee statut);
}
