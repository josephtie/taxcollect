package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.QRCodeContribuableDTO;
import com.nectuxingenieries.collect.tax.dto.RecensementDTO;
import com.nectuxingenieries.collect.tax.dto.RecensementStatsDTO;
import com.nectuxingenieries.collect.tax.services.QRCodeContribuableService;
import com.nectuxingenieries.collect.tax.services.RecensementService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/recensement")
public class RecensementController {

    @Autowired
    private RecensementService recensementService;

    @Autowired
    private QRCodeContribuableService qrCodeContribuableService;

    @PostMapping("/contribuables")
    public ResponseEntity<RecensementDTO> createContribuable(@Valid @RequestBody RecensementDTO dto) {
        RecensementDTO created = recensementService.createRecensement(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/contribuables/{id}")
    public ResponseEntity<RecensementDTO> updateContribuable(@PathVariable Long id, @RequestBody RecensementDTO dto) {
        RecensementDTO updated = recensementService.updateRecensement(id, dto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/contribuables/{id}")
    public ResponseEntity<RecensementDTO> getContribuableById(@PathVariable Long id) {
        RecensementDTO dto = recensementService.findById(id);
        return ResponseEntity.ok(dto);
    }

    @GetMapping("/contribuables")
    public ResponseEntity<List<RecensementDTO>> getAllContribuables() {
        List<RecensementDTO> list = recensementService.findAll();
        return ResponseEntity.ok(list);
    }

    @GetMapping("/contribuables/agent/{agentId}")
    public ResponseEntity<List<RecensementDTO>> getContribuablesByAgent(@PathVariable String agentId) {
        List<RecensementDTO> list = recensementService.findByAgent(agentId);
        return ResponseEntity.ok(list);
    }

    @GetMapping("/contribuables/search")
    public ResponseEntity<List<RecensementDTO>> searchContribuables(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String telephone,
            @RequestParam(required = false) String numeroContribuable,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Long zoneId,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        List<RecensementDTO> results = recensementService.searchContribuables(
                query, telephone, numeroContribuable, type, zoneId, limit, offset);
        return ResponseEntity.ok(results);
    }

    @DeleteMapping("/contribuables/{id}")
    public ResponseEntity<Void> deleteContribuable(@PathVariable Long id) {
        recensementService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/statistics")
    public ResponseEntity<RecensementStatsDTO> getStatistics() {
        RecensementStatsDTO stats = recensementService.getStatistics();
        return ResponseEntity.ok(stats);
    }

    @PostMapping("/contribuables/{id}/qr-code")
    public ResponseEntity<QRCodeContribuableDTO> generateQRCode(@PathVariable Long id) {
        QRCodeContribuableDTO qrCode = qrCodeContribuableService.generateQRCode(id);
        return ResponseEntity.status(HttpStatus.CREATED).body(qrCode);
    }

    @PostMapping("/contribuables/{id}/qr-code/regenerate")
    public ResponseEntity<QRCodeContribuableDTO> regenerateQRCode(@PathVariable Long id) {
        QRCodeContribuableDTO qrCode = qrCodeContribuableService.regenerateQRCode(id);
        return ResponseEntity.ok(qrCode);
    }

    @GetMapping("/contribuables/{id}/qr-code")
    public ResponseEntity<QRCodeContribuableDTO> getActiveQRCode(@PathVariable Long id) {
        return qrCodeContribuableService.getActiveQRCode(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/qr-code/verify")
    public ResponseEntity<QRCodeContribuableDTO> verifyQRCode(
            @RequestParam String qrCodeData,
            @RequestParam(required = false) String agentId,
            Authentication authentication) {
        String agentUsername = authentication != null ? authentication.getName() : agentId;
        QRCodeContribuableDTO result = qrCodeContribuableService.verifyQRCode(qrCodeData, agentUsername);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/contribuables/{id}/qr-codes")
    public ResponseEntity<List<QRCodeContribuableDTO>> getAllQRCodes(@PathVariable Long id) {
        List<QRCodeContribuableDTO> qrCodes = qrCodeContribuableService.getQRCodesByContribuable(id);
        return ResponseEntity.ok(qrCodes);
    }

    @DeleteMapping("/qr-codes/{qrCodeId}")
    public ResponseEntity<Void> deactivateQRCode(@PathVariable Long qrCodeId) {
        qrCodeContribuableService.deactivateQRCode(qrCodeId);
        return ResponseEntity.noContent().build();
    }
}
