package com.nectuxingenieries.collect.tax.payment;

import com.nectuxingenieries.collect.tax.payment.config.PaymentProviderProperties;
import com.nectuxingenieries.collect.tax.payment.dto.PaymentInitiationRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class PaymentProviderFactory {

    private final Map<String, PaymentProvider> providers = new HashMap<>();
    private final PaymentProviderProperties properties;

    @Autowired
    public PaymentProviderFactory(List<PaymentProvider> providerList, PaymentProviderProperties properties) {
        this.properties = properties;
        for (PaymentProvider provider : providerList) {
            providers.put(provider.getProviderCode(), provider);
        }
    }

    public PaymentProvider resolve(PaymentInitiationRequest request) {
        String providerCode = properties.getDefaultProvider();
        PaymentProvider provider = providers.get(providerCode);
        if (provider == null) {
            throw new IllegalStateException("No payment provider found for code: " + providerCode);
        }
        return provider;
    }

    public PaymentProvider resolve(String providerCode) {
        PaymentProvider provider = providers.get(providerCode);
        if (provider == null) {
            throw new IllegalStateException("No payment provider found for code: " + providerCode);
        }
        return provider;
    }
}
