package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PromessePaiement;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PromessePaiementRepository extends BaseRepository<PromessePaiement, Long>, JpaSpecificationExecutor<PromessePaiement> {

    @Query("SELECT p FROM PromessePaiement p WHERE p.contribuable.id = :contribuableId AND p.deletedAt IS NULL ORDER BY p.datePromesse DESC")
    List<PromessePaiement> findByContribuableId(@Param("contribuableId") Long contribuableId);

    @Query("SELECT p FROM PromessePaiement p WHERE p.agent.id = :agentId AND p.deletedAt IS NULL ORDER BY p.dateEcheance ASC")
    List<PromessePaiement> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT p FROM PromessePaiement p WHERE p.statut = :statut AND p.deletedAt IS NULL")
    List<PromessePaiement> findByStatut(@Param("statut") String statut);

    @Query("SELECT p FROM PromessePaiement p WHERE p.dateEcheance <= :date AND p.statut = 'EN_ATTENTE' AND p.deletedAt IS NULL")
    List<PromessePaiement> findEcheancesProches(@Param("date") LocalDate date);
}
