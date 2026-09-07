package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Reconciliation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReconciliationRepository extends JpaRepository<Reconciliation, Long> {
    Optional<Reconciliation> findByReference(String reference);
}
