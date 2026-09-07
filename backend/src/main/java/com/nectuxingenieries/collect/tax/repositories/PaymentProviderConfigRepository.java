package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.PaymentProviderConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentProviderConfigRepository extends JpaRepository<PaymentProviderConfig, Long> {
    List<PaymentProviderConfig> findByEnabledTrueOrderByPriorityAsc();
    List<PaymentProviderConfig> findByCommuneIdAndEnabledTrueOrderByPriorityAsc(Long communeId);
}
