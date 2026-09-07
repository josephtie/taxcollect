package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Transaction;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long>, JpaSpecificationExecutor<Transaction> {

    Optional<Transaction> findByNumeroRecu(String numeroRecu);

    Optional<Transaction> findByHashTransaction(String hashTransaction);

    List<Transaction> findByAgentIdAndDateCreationBetween(Long agentId, LocalDateTime debut, LocalDateTime fin);

    List<Transaction> findByAgentIdAndStatut(Long agentId, StatutTransaction statut);

    List<Transaction> findByOfflineTrue();

    Page<Transaction> findByAgentId(Long agentId, Pageable pageable);

    Page<Transaction> findByZoneId(Long zoneId, Pageable pageable);

    Page<Transaction> findByContribuableId(Long contribuableId, Pageable pageable);

    @Query("SELECT t FROM Transaction t WHERE t.agent.id = :agentId AND t.dateCreation >= :debut AND t.dateCreation <= :fin")
    List<Transaction> findTransactionsByAgentAndDateRange(@Param("agentId") Long agentId,
                                                         @Param("debut") LocalDateTime debut,
                                                         @Param("fin") LocalDateTime fin);

    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.agent.id = :agentId AND t.statut = :statut AND t.dateCreation >= :debut AND t.dateCreation <= :fin")
    Long countTransactionsByAgentAndStatut(@Param("agentId") Long agentId,
                                          @Param("statut") StatutTransaction statut,
                                          @Param("debut") LocalDateTime debut,
                                          @Param("fin") LocalDateTime fin);

    @Query("SELECT SUM(t.montant) FROM Transaction t WHERE t.agent.id = :agentId AND t.modePaiement = :modePaiement AND t.dateCreation >= :debut AND t.dateCreation <= :fin")
    BigDecimal sumMontantByAgentAndModePaiement(@Param("agentId") Long agentId,
                                           @Param("modePaiement") ModePaiement modePaiement,
                                           @Param("debut") LocalDateTime debut,
                                           @Param("fin") LocalDateTime fin);

    @Query("SELECT t FROM Transaction t WHERE t.zone.id = :zoneId AND t.dateCreation >= :debut AND t.dateCreation <= :fin")
    List<Transaction> findTransactionsByZoneAndDateRange(@Param("zoneId") Long zoneId,
                                                        @Param("debut") LocalDateTime debut,
                                                        @Param("fin") LocalDateTime fin);

    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.offline = true")
    Long countOfflineTransactions();

    List<Transaction> findByClotureCaisseId(Long clotureCaisseId);

    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.dateCreation >= :debut AND t.dateCreation <= :fin")
    Long countByDateRange(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);

    @Query("SELECT COALESCE(SUM(t.montant), 0) FROM Transaction t WHERE t.dateCreation >= :debut AND t.dateCreation <= :fin")
    BigDecimal sumMontantByDateRange(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);

    @Query("SELECT t.modePaiement, COUNT(t) FROM Transaction t WHERE t.dateCreation >= :debut AND t.dateCreation <= :fin GROUP BY t.modePaiement")
    List<Object[]> countByModePaiementAndDateRange(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);

    @Query("SELECT t.statut, COUNT(t) FROM Transaction t WHERE t.dateCreation >= :debut AND t.dateCreation <= :fin GROUP BY t.statut")
    List<Object[]> countByStatutAndDateRange(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);
    @Query("SELECT t.modePaiement, COUNT(t) FROM Transaction t GROUP BY t.modePaiement")
    List<Object[]> countByModePaiementAll();

    @Query("SELECT t.statut, COUNT(t) FROM Transaction t GROUP BY t.statut")
    List<Object[]> countByStatutAll();

    @Query("SELECT COALESCE(SUM(t.montant), 0) FROM Transaction t")
    BigDecimal sumMontantAll();
}
