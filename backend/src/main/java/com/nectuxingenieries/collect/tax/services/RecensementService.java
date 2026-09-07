package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.RecensementDTO;
import com.nectuxingenieries.collect.tax.dto.RecensementStatsDTO;
import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class RecensementService {

    private static final String NUMERO_PREFIX = "VTX";

    @Autowired
    private ContribuableRepository contribuableRepository;

    @Autowired
    private ZoneRepository zoneRepository;

    @Autowired
    private QRCodeContribuableService qrCodeContribuableService;

    @Transactional
    public RecensementDTO createRecensement(RecensementDTO dto) {
        if (contribuableRepository.existsByTelephone(dto.getTelephone())) {
            throw new ConflictException("Un contribuable avec ce numéro de téléphone existe déjà");
        }

        Zone zone = zoneRepository.findById(dto.getZoneId())
                .orElseThrow(() -> new NotFoundException("Zone", dto.getZoneId()));

        Contribuable contribuable = new Contribuable();
        contribuable.setNom(dto.getNom());
        contribuable.setPrenom(dto.getPrenoms() != null ? dto.getPrenoms() : dto.getNom());
        contribuable.setTelephone(dto.getTelephone());
        contribuable.setAdresse(dto.getQuartier() != null ? dto.getQuartier() : dto.getMarche());
        contribuable.setLatitude(dto.getLatitude());
        contribuable.setLongitude(dto.getLongitude());
        contribuable.setZone(zone);
        contribuable.setTypeContribuable(dto.getType());
        contribuable.setActivite(dto.getActivite());
        contribuable.setMarche(dto.getMarche());
        contribuable.setQuartier(dto.getQuartier());
        contribuable.setTypePieceIdentite(dto.getTypePiece());
        contribuable.setNumeroPiece(dto.getNumeroPiece());
        contribuable.setPhotoPiece(dto.getPhotoPiece());
        contribuable.setPhotoContribuable(dto.getPhotoContribuable());
        contribuable.setStatut(dto.getStatut() != null ? dto.getStatut() : "actif");
        contribuable.setNecessiteValidation(dto.getNecessiteValidation() != null ? dto.getNecessiteValidation() : false);
        contribuable.setBaseImposable(dto.getBaseImposable());

        Contribuable saved = contribuableRepository.save(contribuable);

        String numeroContribuable = generateNumeroContribuable(saved.getId());
        saved.setNumeroContribuable(numeroContribuable);
        saved = contribuableRepository.save(saved);

        String qrCodeContent = dto.getQrCode() != null ? dto.getQrCode() : generateQRCodeContent(numeroContribuable);

        qrCodeContribuableService.generateQRCodeWithCode(saved.getId(), qrCodeContent);

        return convertToDTO(saved, numeroContribuable, qrCodeContent);
    }

    @Transactional
    public RecensementDTO updateRecensement(Long id, RecensementDTO dto) {
        Contribuable contribuable = contribuableRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Contribuable", id));

        if (dto.getZoneId() != null) {
            Zone zone = zoneRepository.findById(dto.getZoneId())
                    .orElseThrow(() -> new NotFoundException("Zone", dto.getZoneId()));
            contribuable.setZone(zone);
        }

        if (dto.getNom() != null) contribuable.setNom(dto.getNom());
        if (dto.getPrenoms() != null) contribuable.setPrenom(dto.getPrenoms());
        if (dto.getTelephone() != null) contribuable.setTelephone(dto.getTelephone());
        if (dto.getLatitude() != null) contribuable.setLatitude(dto.getLatitude());
        if (dto.getLongitude() != null) contribuable.setLongitude(dto.getLongitude());
        if (dto.getType() != null) contribuable.setTypeContribuable(dto.getType());
        if (dto.getActivite() != null) contribuable.setActivite(dto.getActivite());
        if (dto.getMarche() != null) contribuable.setMarche(dto.getMarche());
        if (dto.getQuartier() != null) contribuable.setQuartier(dto.getQuartier());
        if (dto.getTypePiece() != null) contribuable.setTypePieceIdentite(dto.getTypePiece());
        if (dto.getNumeroPiece() != null) contribuable.setNumeroPiece(dto.getNumeroPiece());
        if (dto.getPhotoPiece() != null) contribuable.setPhotoPiece(dto.getPhotoPiece());
        if (dto.getPhotoContribuable() != null) contribuable.setPhotoContribuable(dto.getPhotoContribuable());
        if (dto.getStatut() != null) contribuable.setStatut(dto.getStatut());
        if (dto.getNecessiteValidation() != null) contribuable.setNecessiteValidation(dto.getNecessiteValidation());
        if (dto.getBaseImposable() != null) contribuable.setBaseImposable(dto.getBaseImposable());

        Contribuable saved = contribuableRepository.save(contribuable);

        String numeroContribuable = NUMERO_PREFIX + String.format("%08d", saved.getId());
        var activeQR = qrCodeContribuableService.getActiveQRCode(saved.getId());
        String qrCode = activeQR.map(q -> q.getCodeQR()).orElse(null);

        return convertToDTO(saved, numeroContribuable, qrCode);
    }

    @Transactional(readOnly = true)
    public RecensementDTO findById(Long id) {
        Contribuable contribuable = contribuableRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Contribuable", id));
        String numeroContribuable = NUMERO_PREFIX + String.format("%08d", contribuable.getId());
        var activeQR = qrCodeContribuableService.getActiveQRCode(contribuable.getId());
        String qrCode = activeQR.map(q -> q.getCodeQR()).orElse(null);
        return convertToDTO(contribuable, numeroContribuable, qrCode);
    }

    @Transactional(readOnly = true)
    public List<RecensementDTO> findAll() {
        return contribuableRepository.findAll().stream()
                .map(c -> {
                    String numero = NUMERO_PREFIX + String.format("%08d", c.getId());
                    var activeQR = qrCodeContribuableService.getActiveQRCode(c.getId());
                    String qrCode = activeQR.map(q -> q.getCodeQR()).orElse(null);
                    return convertToDTO(c, numero, qrCode);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RecensementDTO> findByAgent(String agentId) {
        return contribuableRepository.searchByNomPrenomOrTelephone(agentId).stream()
                .map(c -> {
                    String numero = NUMERO_PREFIX + String.format("%08d", c.getId());
                    var activeQR = qrCodeContribuableService.getActiveQRCode(c.getId());
                    String qrCode = activeQR.map(q -> q.getCodeQR()).orElse(null);
                    return convertToDTO(c, numero, qrCode);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RecensementDTO> searchContribuables(String query, String telephone, String numeroContribuable,
                                                      String type, Long zoneId, int limit, int offset) {
        List<Contribuable> results;

        if (telephone != null && !telephone.isEmpty()) {
            results = contribuableRepository.searchByNomPrenomOrTelephone(telephone);
        } else if (query != null && !query.isEmpty()) {
            results = contribuableRepository.searchByNomPrenomOrTelephone(query);
        } else if (zoneId != null) {
            results = contribuableRepository.findByZoneId(zoneId);
        } else {
            results = contribuableRepository.findAll();
        }

        return results.stream()
                .skip(offset)
                .limit(limit)
                .map(c -> {
                    String numero = NUMERO_PREFIX + String.format("%08d", c.getId());
                    var activeQR = qrCodeContribuableService.getActiveQRCode(c.getId());
                    String qrCode = activeQR.map(q -> q.getCodeQR()).orElse(null);
                    return convertToDTO(c, numero, qrCode);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public RecensementStatsDTO getStatistics() {
        RecensementStatsDTO stats = new RecensementStatsDTO();

        long total = contribuableRepository.count();
        stats.setTotalContribuables(total);

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(23, 59, 59);

        Long creesAujourdhui = contribuableRepository.countByCreatedAtBetween(todayStart, todayEnd);
        stats.setCreesAujourdhui(creesAujourdhui != null ? creesAujourdhui : 0L);

        Long misAJourAujourdhui = contribuableRepository.countByUpdatedAtBetween(todayStart, todayEnd);
        stats.setMisAJourAujourdhui(misAJourAujourdhui != null ? misAJourAujourdhui : 0L);

        stats.setEnValidation(0L);
        stats.setNonSynchronises(0L);
        stats.setTauxSynchronisation(total > 0 ? 100.0 : 0.0);

        Map<String, Long> repartitionZone = new HashMap<>();
        List<Object[]> zoneCounts = contribuableRepository.countByZone();
        for (Object[] row : zoneCounts) {
            String zoneNom = (String) row[0];
            Long count = (Long) row[1];
            repartitionZone.put(zoneNom, count);
        }
        stats.setRepartitionParZone(repartitionZone);

        stats.setRepartitionParType(new HashMap<>());

        return stats;
    }

    @Transactional
    public void delete(Long id) {
        Contribuable contribuable = contribuableRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Contribuable", id));
        contribuableRepository.delete(contribuable);
    }

    private String generateNumeroContribuable(Long contribuableId) {
        return NUMERO_PREFIX + String.format("%08d", contribuableId);
    }

    private String generateQRCodeContent(String numeroContribuable) {
        return "VTXQR_" + numeroContribuable + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private RecensementDTO convertToDTO(Contribuable contribuable, String numeroContribuable, String qrCode) {
        RecensementDTO dto = new RecensementDTO();
        dto.setId(contribuable.getId());
        dto.setNom(contribuable.getNom());
        dto.setPrenoms(contribuable.getPrenom());
        dto.setTelephone(contribuable.getTelephone());
        dto.setZoneId(contribuable.getZone().getId());
        dto.setLatitude(contribuable.getLatitude());
        dto.setLongitude(contribuable.getLongitude());
        dto.setQuartier(contribuable.getQuartier());
        dto.setMarche(contribuable.getMarche());
        dto.setType(contribuable.getTypeContribuable());
        dto.setActivite(contribuable.getActivite());
        dto.setTypePiece(contribuable.getTypePieceIdentite());
        dto.setNumeroPiece(contribuable.getNumeroPiece());
        dto.setPhotoPiece(contribuable.getPhotoPiece());
        dto.setPhotoContribuable(contribuable.getPhotoContribuable());
        dto.setNumeroContribuable(contribuable.getNumeroContribuable() != null ? contribuable.getNumeroContribuable() : numeroContribuable);
        dto.setQrCode(qrCode);
        dto.setStatut(contribuable.getStatut());
        dto.setVersion(1);
        dto.setNecessiteValidation(contribuable.getNecessiteValidation());
        dto.setBaseImposable(contribuable.getBaseImposable());
        return dto;
    }
}
