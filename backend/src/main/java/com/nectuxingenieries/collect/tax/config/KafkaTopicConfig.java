package com.nectuxingenieries.collect.tax.config;

import com.nectuxingenieries.collect.tax.payment.PaymentEventProducer;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfig {

    @Bean
    public NewTopic paymentInitiatedTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_INITIATED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic paymentPendingTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_PENDING)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic paymentSucceededTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_SUCCEEDED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic paymentFailedTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_FAILED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic paymentCancelledTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_CANCELLED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic paymentRefundedTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_PAYMENT_REFUNDED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic receiptGeneratedTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_RECEIPT_GENERATED)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic reconciliationTopic() {
        return TopicBuilder.name(PaymentEventProducer.TOPIC_RECONCILIATION)
                .partitions(3)
                .replicas(1)
                .build();
    }
}
