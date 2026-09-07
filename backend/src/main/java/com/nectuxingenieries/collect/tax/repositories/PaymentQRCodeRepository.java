package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PaymentQRCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentQRCodeRepository extends JpaRepository<PaymentQRCode, Long> {
    Optional<PaymentQRCode> findByToken(String token);
    Optional<PaymentQRCode> findByCollectionOrderIdAndActifTrue(Long collectionOrderId);
}
