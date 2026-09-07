package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Settlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, Long> {
    Optional<Settlement> findByReference(String reference);
    Optional<Settlement> findByReconciliationId(Long reconciliationId);
}
