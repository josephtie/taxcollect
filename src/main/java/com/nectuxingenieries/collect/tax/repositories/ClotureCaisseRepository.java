package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.ClotureCaisse;
import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ClotureCaisseRepository extends JpaRepository<ClotureCaisse, Long> {

    Optional<ClotureCaisse> findByAgentIdAndDateCloture(Long agentId, LocalDate dateCloture);

    List<ClotureCaisse> findByAgentIdOrderByDateClotureDesc(Long agentId);

    List<ClotureCaisse> findByStatut(StatutCloture statut);

    List<ClotureCaisse> findByDateClotureBetween(LocalDate debut, LocalDate fin);

    @Query("SELECT c FROM ClotureCaisse c WHERE c.statut = :statut ORDER BY c.dateCloture DESC")
    List<ClotureCaisse> findByStatutOrderByDateClotureDesc(@Param("statut") StatutCloture statut);

    @Query("SELECT COUNT(c) FROM ClotureCaisse c WHERE c.agent.id = :agentId AND c.statut = :statut AND c.dateCloture >= :debut AND c.dateCloture <= :fin")
    Long countByAgentAndStatutAndDateRange(@Param("agentId") Long agentId,
                                          @Param("statut") StatutCloture statut,
                                          @Param("debut") LocalDate debut,
                                          @Param("fin") LocalDate fin);

    @Query("SELECT c FROM ClotureCaisse c WHERE c.dateCloture = :date AND c.statut IN :statuts")
    List<ClotureCaisse> findByDateClotureAndStatutIn(@Param("date") LocalDate date,
                                                     @Param("statuts") List<StatutCloture> statuts);

    boolean existsByAgentIdAndDateCloture(Long agentId, LocalDate dateCloture);
}
