package com.nectuxingenieries.collect.tax.payment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class PaymentEventProducer {

    public static final String TOPIC_PAYMENT_INITIATED = "ecollecttaxe.payment.PaymentInitiated";
    public static final String TOPIC_PAYMENT_PENDING = "ecollecttaxe.payment.PaymentPending";
    public static final String TOPIC_PAYMENT_SUCCEEDED = "ecollecttaxe.payment.PaymentSucceeded";
    public static final String TOPIC_PAYMENT_FAILED = "ecollecttaxe.payment.PaymentFailed";
    public static final String TOPIC_PAYMENT_CANCELLED = "ecollecttaxe.payment.PaymentCancelled";
    public static final String TOPIC_PAYMENT_REFUNDED = "ecollecttaxe.payment.PaymentRefunded";
    public static final String TOPIC_RECEIPT_GENERATED = "ecollecttaxe.payment.ReceiptGenerated";
    public static final String TOPIC_RECONCILIATION = "ecollecttaxe.payment.ReconciliationCompleted";

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    public void publishPaymentInitiated(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_INITIATED, transactionReference, payload);
    }

    public void publishPaymentPending(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_PENDING, transactionReference, payload);
    }

    public void publishPaymentSucceeded(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_SUCCEEDED, transactionReference, payload);
    }

    public void publishPaymentFailed(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_FAILED, transactionReference, payload);
    }

    public void publishPaymentCancelled(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_CANCELLED, transactionReference, payload);
    }

    public void publishPaymentRefunded(String transactionReference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_PAYMENT_REFUNDED, transactionReference, payload);
    }

    public void publishReceiptGenerated(String receiptNumber, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_RECEIPT_GENERATED, receiptNumber, payload);
    }

    public void publishReconciliation(String reference, Map<String, Object> payload) {
        kafkaTemplate.send(TOPIC_RECONCILIATION, reference, payload);
    }
}
