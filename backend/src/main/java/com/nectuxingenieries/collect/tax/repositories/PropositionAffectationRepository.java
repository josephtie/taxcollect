package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PropositionAffectation;
import com.nectuxingenieries.collect.tax.models.enums.StatutProposition;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PropositionAffectationRepository extends BaseRepository<PropositionAffectation, Long>, JpaSpecificationExecutor<PropositionAffectation> {

    @Query("SELECT p FROM PropositionAffectation p WHERE p.quartierId = :quartierId AND p.statut = :statut AND p.deletedAt IS NULL ORDER BY p.createdAt DESC")
    List<PropositionAffectation> findByQuartierIdAndStatut(@Param("quartierId") Long quartierId, @Param("statut") StatutProposition statut);

    @Query("SELECT p FROM PropositionAffectation p WHERE p.quartierId = :quartierId AND p.deletedAt IS NULL ORDER BY p.createdAt DESC")
    List<PropositionAffectation> findByQuartierId(@Param("quartierId") Long quartierId);

    @Query("SELECT p FROM PropositionAffectation p WHERE p.statut = :statut AND p.deletedAt IS NULL ORDER BY p.createdAt DESC")
    List<PropositionAffectation> findByStatut(@Param("statut") StatutProposition statut);
}
