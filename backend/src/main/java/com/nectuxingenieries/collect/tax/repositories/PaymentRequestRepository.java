package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PaymentRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentRequestRepository extends JpaRepository<PaymentRequest, Long> {
    Optional<PaymentRequest> findByReference(String reference);
}
