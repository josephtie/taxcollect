package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.PaymentQRCode;
import com.nectuxingenieries.collect.tax.repositories.PaymentQRCodeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@Transactional
public class PaymentQRCodeService {

    @Autowired
    private PaymentQRCodeRepository paymentQRCodeRepository;

    public PaymentQRCode generateQRCode(Long collectionOrderId) {
        PaymentQRCode qrCode = new PaymentQRCode();
        qrCode.setToken(UUID.randomUUID().toString().replace("-", ""));
        qrCode.setCollectionOrderId(collectionOrderId);
        qrCode.setPayload("https://pay.ecollecttaxe.ci/q/" + qrCode.getToken());
        qrCode.setGeneratedAt(LocalDateTime.now());
        qrCode.setExpiresAt(LocalDateTime.now().plusHours(24));
        qrCode.setActif(true);
        return paymentQRCodeRepository.save(qrCode);
    }

    @Transactional(readOnly = true)
    public PaymentQRCode resolveQRCode(String token) {
        PaymentQRCode qrCode = paymentQRCodeRepository.findByToken(token)
                .orElseThrow(() -> new NotFoundException("PaymentQRCode", token));

        if (!qrCode.isActif()) {
            throw new IllegalStateException("QR Code inactif");
        }
        if (qrCode.getExpiresAt() != null && qrCode.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalStateException("QR Code expiré");
        }
        return qrCode;
    }

    public void invalidateQRCode(Long id) {
        PaymentQRCode qrCode = paymentQRCodeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("PaymentQRCode", id));
        qrCode.setActif(false);
        qrCode.setUsedAt(LocalDateTime.now());
        paymentQRCodeRepository.save(qrCode);
    }
}
