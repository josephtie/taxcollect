package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.CollectionOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CollectionOrderRepository extends JpaRepository<CollectionOrder, Long> {
    Optional<CollectionOrder> findByReference(String reference);
}
