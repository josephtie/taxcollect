package com.nectuxingenieries.collect.tax.config;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfig {

    @Autowired
    private MeterRegistry meterRegistry;

    @Bean
    public Counter paymentInitiatedCounter() {
        return Counter.builder("ecollecttaxe_payment_initiated_total")
                .description("Total number of payment initiations")
                .tag("module", "payment")
                .register(meterRegistry);
    }

    @Bean
    public Counter paymentSucceededCounter() {
        return Counter.builder("ecollecttaxe_payment_succeeded_total")
                .description("Total number of successful payments")
                .tag("module", "payment")
                .register(meterRegistry);
    }

    @Bean
    public Counter paymentFailedCounter() {
        return Counter.builder("ecollecttaxe_payment_failed_total")
                .description("Total number of failed payments")
                .tag("module", "payment")
                .register(meterRegistry);
    }

    @Bean
    public Counter paymentRefundedCounter() {
        return Counter.builder("ecollecttaxe_payment_refunded_total")
                .description("Total number of refunded payments")
                .tag("module", "payment")
                .register(meterRegistry);
    }

    @Bean
    public Counter smsSentCounter() {
        return Counter.builder("ecollecttaxe_sms_sent_total")
                .description("Total number of SMS notifications sent")
                .tag("module", "notification")
                .register(meterRegistry);
    }

    @Bean
    public Counter smsFailedCounter() {
        return Counter.builder("ecollecttaxe_sms_failed_total")
                .description("Total number of SMS notifications that failed")
                .tag("module", "notification")
                .register(meterRegistry);
    }

    @Bean
    public Timer paymentProcessingTimer() {
        return Timer.builder("ecollecttaxe_payment_processing_duration")
                .description("Time taken to process a payment")
                .tag("module", "payment")
                .register(meterRegistry);
    }
}
