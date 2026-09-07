package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.models.enums.StatutPayment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface TaxeCollectRepository extends JpaRepository<TaxeCollect, Long>, JpaSpecificationExecutor<TaxeCollect> {

    List<TaxeCollect> findByZoneId(Long communeId);
    Page<TaxeCollect> findByZoneId(Long communeId, Pageable pageable);

    @Query("SELECT tc FROM TaxeCollect tc WHERE tc.contribuable.id = :contribuableId AND tc.taxType = :taxType AND tc.periodStart = :periodStart")
    Optional<TaxeCollect> findByContribuableAndTaxeAndPeriodStart(@Param("contribuableId") Long contribuableId, @Param("taxType") String taxType, @Param("periodStart") LocalDate periodStart);

    @Query("SELECT tc FROM TaxeCollect tc WHERE tc.statut = :statut AND tc.dueDate < :today")
    List<TaxeCollect> findOverdueAssessments(@Param("statut") StatutPayment statut, @Param("today") LocalDate today);
}

