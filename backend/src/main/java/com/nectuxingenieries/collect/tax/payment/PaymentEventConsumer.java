package com.nectuxingenieries.collect.tax.payment;

import com.nectuxingenieries.collect.tax.services.SmsNotificationService;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@Log4j2
public class PaymentEventConsumer {

    @Autowired
    private SmsNotificationService smsNotificationService;

    @KafkaListener(topics = PaymentEventProducer.TOPIC_PAYMENT_SUCCEEDED, groupId = "${spring.kafka.consumer.group-id}")
    public void onPaymentSucceeded(Map<String, Object> payload) {
        log.info("PaymentSucceeded event received: {}", payload.get("transactionReference"));

        String phoneNumber = (String) payload.get("taxpayerPhone");
        String reference = (String) payload.get("transactionReference");
        String amount = String.valueOf(payload.get("amount"));
        String currency = (String) payload.getOrDefault("currency", "XOF");

        if (phoneNumber != null && !phoneNumber.isBlank()) {
            smsNotificationService.sendPaymentConfirmationSms(phoneNumber, reference, amount, currency);
        }
    }

    @KafkaListener(topics = PaymentEventProducer.TOPIC_PAYMENT_FAILED, groupId = "${spring.kafka.consumer.group-id}")
    public void onPaymentFailed(Map<String, Object> payload) {
        log.info("PaymentFailed event received: {}", payload.get("transactionReference"));
    }

    @KafkaListener(topics = PaymentEventProducer.TOPIC_PAYMENT_CANCELLED, groupId = "${spring.kafka.consumer.group-id}")
    public void onPaymentCancelled(Map<String, Object> payload) {
        log.info("PaymentCancelled event received: {}", payload.get("transactionReference"));
    }

    @KafkaListener(topics = PaymentEventProducer.TOPIC_PAYMENT_REFUNDED, groupId = "${spring.kafka.consumer.group-id}")
    public void onPaymentRefunded(Map<String, Object> payload) {
        log.info("PaymentRefunded event received: {}", payload.get("transactionReference"));
    }

    @KafkaListener(topics = PaymentEventProducer.TOPIC_RECEIPT_GENERATED, groupId = "${spring.kafka.consumer.group-id}")
    public void onReceiptGenerated(Map<String, Object> payload) {
        log.info("ReceiptGenerated event received: {}", payload.get("receiptNumber"));
    }

    @KafkaListener(topics = PaymentEventProducer.TOPIC_RECONCILIATION, groupId = "${spring.kafka.consumer.group-id}")
    public void onReconciliationCompleted(Map<String, Object> payload) {
        log.info("ReconciliationCompleted event received: {}", payload.get("reference"));
    }
}
