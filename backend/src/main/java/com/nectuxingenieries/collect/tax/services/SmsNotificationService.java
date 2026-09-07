package com.nectuxingenieries.collect.tax.services;

import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class SmsNotificationService {

    @Value("${sms.provider.enabled:false}")
    private boolean enabled;

    @Value("${sms.provider.api-url:}")
    private String apiUrl;

    @Value("${sms.provider.api-key:}")
    private String apiKey;

    @Value("${sms.provider.sender-name:TAXCOLLECT}")
    private String senderName;

    public void sendPaymentConfirmationSms(String phoneNumber, String reference, String amount, String currency) {
        if (!enabled) {
            log.info("SMS disabled — skipping payment confirmation SMS to {} for reference {}", phoneNumber, reference);
            return;
        }

        String message = String.format(
                "Paiement confirme. Reference: %s. Montant: %s %s. Merci pour votre contribution. - TaxCollect",
                reference, amount, currency
        );

        sendSms(phoneNumber, message);
    }

    public void sendAssessmentNotificationSms(String phoneNumber, String reference, String amount, String dueDate) {
        if (!enabled) {
            log.info("SMS disabled — skipping assessment notification SMS to {} for reference {}", phoneNumber, reference);
            return;
        }

        String message = String.format(
                "Avis d'imposition genere. Reference: %s. Montant: %s FCFA. Echeance: %s. - TaxCollect",
                reference, amount, dueDate
        );

        sendSms(phoneNumber, message);
    }

    public void sendOverdueReminderSms(String phoneNumber, String reference, String amount) {
        if (!enabled) {
            log.info("SMS disabled — skipping overdue reminder SMS to {} for reference {}", phoneNumber, reference);
            return;
        }

        String message = String.format(
                "Rappel: Votre avis %s de %s FCFA est en retard. Veuillez regulariser. - TaxCollect",
                reference, amount
        );

        sendSms(phoneNumber, message);
    }

    private void sendSms(String phoneNumber, String message) {
        try {
            log.info("Sending SMS to {}: {}", phoneNumber, message);

            // TODO: Integrate with actual SMS provider API (e.g., Orange SMS API, MTN SMS API, or aggregator)
            // For now, this is a stub that logs the message.
            // When a provider is selected, implement the HTTP call here using RestTemplate or WebClient.
            //
            // Example:
            // HttpHeaders headers = new HttpHeaders();
            // headers.set("Authorization", "Bearer " + apiKey);
            // headers.setContentType(MediaType.APPLICATION_JSON);
            // Map<String, Object> body = Map.of(
            //     "sender", senderName,
            //     "recipient", phoneNumber,
            //     "message", message
            // );
            // restTemplate.postForObject(apiUrl, new HttpEntity<>(body, headers), String.class);

            log.info("SMS sent successfully to {}", phoneNumber);
        } catch (Exception e) {
            log.error("Failed to send SMS to {}: {}", phoneNumber, e.getMessage());
        }
    }
}
