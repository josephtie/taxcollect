package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.QRCodeContribuableDTO;
import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.QRCodeContribuable;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.QRCodeContribuableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class QRCodeContribuableService {

    private static final String QR_CODE_PREFIX = "VTX";
    private static final int QR_CODE_VALIDITY_MONTHS = 12;

    @Autowired
    private QRCodeContribuableRepository qrCodeRepository;

    @Autowired
    private ContribuableRepository contribuableRepository;

    @Transactional
    public QRCodeContribuableDTO generateQRCode(Long contribuableId) {
        Contribuable contribuable = contribuableRepository.findById(contribuableId)
                .orElseThrow(() -> new NotFoundException("Contribuable", contribuableId));

        String codeQR = QR_CODE_PREFIX + "_" + UUID.randomUUID().toString().replace("-", "").toUpperCase();

        QRCodeContribuable qrCode = new QRCodeContribuable();
        qrCode.setCodeQR(codeQR);
        qrCode.setContribuable(contribuable);
        qrCode.setDateGeneration(LocalDateTime.now());
        qrCode.setActif(true);
        qrCode.setDateExpiration(LocalDateTime.now().plusMonths(QR_CODE_VALIDITY_MONTHS));

        QRCodeContribuable saved = qrCodeRepository.save(qrCode);
        return convertToDTO(saved);
    }

    @Transactional
    public QRCodeContribuableDTO generateQRCodeWithCode(Long contribuableId, String codeQR) {
        Contribuable contribuable = contribuableRepository.findById(contribuableId)
                .orElseThrow(() -> new NotFoundException("Contribuable", contribuableId));

        if (qrCodeRepository.existsByCodeQR(codeQR)) {
            throw new ConflictException("Un QR code avec ce contenu existe déjà: " + codeQR);
        }

        QRCodeContribuable qrCode = new QRCodeContribuable();
        qrCode.setCodeQR(codeQR);
        qrCode.setContribuable(contribuable);
        qrCode.setDateGeneration(LocalDateTime.now());
        qrCode.setActif(true);
        qrCode.setDateExpiration(LocalDateTime.now().plusMonths(QR_CODE_VALIDITY_MONTHS));

        QRCodeContribuable saved = qrCodeRepository.save(qrCode);
        return convertToDTO(saved);
    }

    @Transactional(readOnly = true)
    public QRCodeContribuableDTO verifyQRCode(String codeQR, String agentUsername) {
        QRCodeContribuable qrCode = qrCodeRepository.findByCodeQR(codeQR)
                .orElseThrow(() -> new NotFoundException("QR Code", codeQR));

        if (!qrCode.getActif()) {
            throw new InvalidOperationException("Ce QR code a été désactivé");
        }

        if (qrCode.getDateExpiration() != null && qrCode.getDateExpiration().isBefore(LocalDateTime.now())) {
            qrCode.setActif(false);
            qrCodeRepository.save(qrCode);
            throw new InvalidOperationException("Ce QR code a expiré");
        }

        qrCode.setUtilisePar(agentUsername);
        qrCodeRepository.save(qrCode);

        return convertToDTO(qrCode);
    }

    @Transactional
    public QRCodeContribuableDTO regenerateQRCode(Long contribuableId) {
        List<QRCodeContribuable> activeCodes = qrCodeRepository.findActiveQRCodeByContribuable(contribuableId);
        for (QRCodeContribuable qrCode : activeCodes) {
            qrCode.setActif(false);
            qrCodeRepository.save(qrCode);
        }

        return generateQRCode(contribuableId);
    }

    @Transactional
    public void deactivateQRCode(Long qrCodeId) {
        QRCodeContribuable qrCode = qrCodeRepository.findById(qrCodeId)
                .orElseThrow(() -> new NotFoundException("QR Code", qrCodeId));
        qrCode.setActif(false);
        qrCodeRepository.save(qrCode);
    }

    @Transactional(readOnly = true)
    public List<QRCodeContribuableDTO> getQRCodesByContribuable(Long contribuableId) {
        return qrCodeRepository.findByContribuableId(contribuableId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Optional<QRCodeContribuableDTO> getActiveQRCode(Long contribuableId) {
        List<QRCodeContribuable> activeCodes = qrCodeRepository.findActiveQRCodeByContribuable(contribuableId);
        if (activeCodes.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(convertToDTO(activeCodes.get(0)));
    }

    @Transactional
    public int deactivateExpiredQRCodes() {
        List<QRCodeContribuable> expired = qrCodeRepository.findExpiredQRCode(LocalDateTime.now());
        for (QRCodeContribuable qrCode : expired) {
            qrCode.setActif(false);
            qrCodeRepository.save(qrCode);
        }
        return expired.size();
    }

    private QRCodeContribuableDTO convertToDTO(QRCodeContribuable qrCode) {
        QRCodeContribuableDTO dto = new QRCodeContribuableDTO();
        dto.setId(qrCode.getId());
        dto.setCodeQR(qrCode.getCodeQR());
        dto.setContribuableId(qrCode.getContribuable().getId());
        dto.setContribuableNom(qrCode.getContribuable().getNom());
        dto.setContribuablePrenom(qrCode.getContribuable().getPrenom());
        dto.setDateGeneration(qrCode.getDateGeneration());
        dto.setActif(qrCode.getActif());
        dto.setDateExpiration(qrCode.getDateExpiration());
        dto.setUtilisePar(qrCode.getUtilisePar());
        return dto;
    }
}
