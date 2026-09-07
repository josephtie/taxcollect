package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PaymentAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentAttemptRepository extends JpaRepository<PaymentAttempt, Long> {
    List<PaymentAttempt> findByCollectionOrderId(Long collectionOrderId);
}
