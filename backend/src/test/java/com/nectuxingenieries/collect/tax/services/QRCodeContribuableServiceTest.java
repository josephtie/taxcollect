package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.QRCodeContribuableDTO;
import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.QRCodeContribuable;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.QRCodeContribuableRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class QRCodeContribuableServiceTest {

    @Mock
    private QRCodeContribuableRepository qrCodeRepository;

    @Mock
    private ContribuableRepository contribuableRepository;

    @InjectMocks
    private QRCodeContribuableService qrCodeContribuableService;

    private Contribuable contribuable;
    private QRCodeContribuable qrCode;

    @BeforeEach
    void setUp() {
        Zone zone = new Zone();
        zone.setId(1L);
        zone.setNom("Marché central");

        contribuable = new Contribuable();
        contribuable.setId(10L);
        contribuable.setNom("Mwamba");
        contribuable.setPrenom("Augustin");
        contribuable.setZone(zone);

        qrCode = new QRCodeContribuable();
        qrCode.setId(1L);
        qrCode.setCodeQR("VTXQR_VTX00000010_A1B2C3D4");
        qrCode.setContribuable(contribuable);
        qrCode.setDateGeneration(LocalDateTime.now());
        qrCode.setActif(true);
        qrCode.setDateExpiration(LocalDateTime.now().plusMonths(12));
    }

    @Test
    void generateQRCode_shouldCreateAndReturnDTO() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenReturn(qrCode);

        QRCodeContribuableDTO result = qrCodeContribuableService.generateQRCode(10L);

        assertNotNull(result);
        assertEquals("VTXQR_VTX00000010_A1B2C3D4", result.getCodeQR());
        assertEquals(10L, result.getContribuableId());
        assertEquals("Mwamba", result.getContribuableNom());
        assertTrue(result.getActif());
        verify(qrCodeRepository).save(any(QRCodeContribuable.class));
    }

    @Test
    void generateQRCode_shouldThrowNotFound_whenContribuableDoesNotExist() {
        when(contribuableRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> qrCodeContribuableService.generateQRCode(99L));
        verify(qrCodeRepository, never()).save(any());
    }

    @Test
    void generateQRCodeWithCode_shouldThrowConflict_whenCodeAlreadyExists() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(qrCodeRepository.existsByCodeQR("EXISTING_CODE")).thenReturn(true);

        assertThrows(ConflictException.class,
                () -> qrCodeContribuableService.generateQRCodeWithCode(10L, "EXISTING_CODE"));
        verify(qrCodeRepository, never()).save(any());
    }

    @Test
    void generateQRCodeWithCode_shouldSucceed_whenCodeIsUnique() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(qrCodeRepository.existsByCodeQR("NEW_CODE")).thenReturn(false);
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenReturn(qrCode);

        QRCodeContribuableDTO result = qrCodeContribuableService.generateQRCodeWithCode(10L, "NEW_CODE");

        assertNotNull(result);
        verify(qrCodeRepository).save(any(QRCodeContribuable.class));
    }

    @Test
    void verifyQRCode_shouldReturnDTO_whenValidAndActive() {
        when(qrCodeRepository.findByCodeQR("VTXQR_VTX00000010_A1B2C3D4")).thenReturn(Optional.of(qrCode));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenReturn(qrCode);

        QRCodeContribuableDTO result = qrCodeContribuableService.verifyQRCode("VTXQR_VTX00000010_A1B2C3D4", "joseph");

        assertNotNull(result);
        assertEquals("joseph", qrCode.getUtilisePar());
        verify(qrCodeRepository).save(qrCode);
    }

    @Test
    void verifyQRCode_shouldThrowNotFound_whenCodeDoesNotExist() {
        when(qrCodeRepository.findByCodeQR("UNKNOWN")).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class,
                () -> qrCodeContribuableService.verifyQRCode("UNKNOWN", "joseph"));
    }

    @Test
    void verifyQRCode_shouldThrowInvalidOperation_whenQRCodeInactive() {
        qrCode.setActif(false);
        when(qrCodeRepository.findByCodeQR("VTXQR_VTX00000010_A1B2C3D4")).thenReturn(Optional.of(qrCode));

        assertThrows(InvalidOperationException.class,
                () -> qrCodeContribuableService.verifyQRCode("VTXQR_VTX00000010_A1B2C3D4", "joseph"));
    }

    @Test
    void verifyQRCode_shouldDeactivateAndThrow_whenExpired() {
        qrCode.setDateExpiration(LocalDateTime.now().minusDays(1));
        when(qrCodeRepository.findByCodeQR("VTXQR_VTX00000010_A1B2C3D4")).thenReturn(Optional.of(qrCode));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenReturn(qrCode);

        assertThrows(InvalidOperationException.class,
                () -> qrCodeContribuableService.verifyQRCode("VTXQR_VTX00000010_A1B2C3D4", "joseph"));
        assertFalse(qrCode.getActif());
    }

    @Test
    void regenerateQRCode_shouldDeactivateOldAndGenerateNew() {
        QRCodeContribuable oldActive = new QRCodeContribuable();
        oldActive.setId(2L);
        oldActive.setCodeQR("OLD_CODE");
        oldActive.setContribuable(contribuable);
        oldActive.setActif(true);

        when(qrCodeRepository.findActiveQRCodeByContribuable(10L))
                .thenReturn(List.of(oldActive))
                .thenReturn(List.of());
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenAnswer(inv -> inv.getArgument(0));

        QRCodeContribuableDTO result = qrCodeContribuableService.regenerateQRCode(10L);

        assertNotNull(result);
        assertFalse(oldActive.getActif());
        verify(qrCodeRepository, atLeast(2)).save(any(QRCodeContribuable.class));
    }

    @Test
    void deactivateQRCode_shouldSetInactive() {
        when(qrCodeRepository.findById(1L)).thenReturn(Optional.of(qrCode));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenReturn(qrCode);

        qrCodeContribuableService.deactivateQRCode(1L);

        assertFalse(qrCode.getActif());
        verify(qrCodeRepository).save(qrCode);
    }

    @Test
    void deactivateQRCode_shouldThrowNotFound_whenIdDoesNotExist() {
        when(qrCodeRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> qrCodeContribuableService.deactivateQRCode(99L));
    }

    @Test
    void getQRCodesByContribuable_shouldReturnList() {
        when(qrCodeRepository.findByContribuableId(10L)).thenReturn(Arrays.asList(qrCode));

        List<QRCodeContribuableDTO> result = qrCodeContribuableService.getQRCodesByContribuable(10L);

        assertEquals(1, result.size());
        assertEquals("VTXQR_VTX00000010_A1B2C3D4", result.get(0).getCodeQR());
    }

    @Test
    void getActiveQRCode_shouldReturnEmpty_whenNoActiveCode() {
        when(qrCodeRepository.findActiveQRCodeByContribuable(10L)).thenReturn(List.of());

        Optional<QRCodeContribuableDTO> result = qrCodeContribuableService.getActiveQRCode(10L);

        assertTrue(result.isEmpty());
    }

    @Test
    void getActiveQRCode_shouldReturnDTO_whenActiveCodeExists() {
        when(qrCodeRepository.findActiveQRCodeByContribuable(10L)).thenReturn(List.of(qrCode));

        Optional<QRCodeContribuableDTO> result = qrCodeContribuableService.getActiveQRCode(10L);

        assertTrue(result.isPresent());
        assertEquals("VTXQR_VTX00000010_A1B2C3D4", result.get().getCodeQR());
    }

    @Test
    void deactivateExpiredQRCodes_shouldDeactivateAllExpired() {
        QRCodeContribuable expired1 = new QRCodeContribuable();
        expired1.setId(1L);
        expired1.setActif(true);
        expired1.setDateExpiration(LocalDateTime.now().minusDays(5));

        QRCodeContribuable expired2 = new QRCodeContribuable();
        expired2.setId(2L);
        expired2.setActif(true);
        expired2.setDateExpiration(LocalDateTime.now().minusDays(1));

        when(qrCodeRepository.findExpiredQRCode(any(LocalDateTime.class)))
                .thenReturn(Arrays.asList(expired1, expired2));
        when(qrCodeRepository.save(any(QRCodeContribuable.class))).thenAnswer(inv -> inv.getArgument(0));

        int count = qrCodeContribuableService.deactivateExpiredQRCodes();

        assertEquals(2, count);
        assertFalse(expired1.getActif());
        assertFalse(expired2.getActif());
    }
}
