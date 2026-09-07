package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.QRCodeContribuableDTO;
import com.nectuxingenieries.collect.tax.dto.RecensementDTO;
import com.nectuxingenieries.collect.tax.dto.RecensementStatsDTO;
import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
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
class RecensementServiceTest {

    @Mock
    private ContribuableRepository contribuableRepository;

    @Mock
    private ZoneRepository zoneRepository;

    @Mock
    private QRCodeContribuableService qrCodeContribuableService;

    @InjectMocks
    private RecensementService recensementService;

    private Zone zone;
    private Contribuable contribuable;
    private RecensementDTO recensementDTO;

    @BeforeEach
    void setUp() {
        zone = new Zone();
        zone.setId(1L);
        zone.setNom("Marché central");

        contribuable = new Contribuable();
        contribuable.setId(10L);
        contribuable.setNom("Mwamba");
        contribuable.setPrenom("Augustin");
        contribuable.setTelephone("+243812345678");
        contribuable.setZone(zone);
        contribuable.setTypeContribuable("personne_physique");
        contribuable.setActivite("Commerçant");
        contribuable.setStatut("actif");

        recensementDTO = new RecensementDTO();
        recensementDTO.setNom("Mwamba");
        recensementDTO.setPrenoms("Augustin");
        recensementDTO.setTelephone("+243812345678");
        recensementDTO.setType("personne_physique");
        recensementDTO.setActivite("Commerçant");
        recensementDTO.setZoneId(1L);
        recensementDTO.setTypePiece("cni");
        recensementDTO.setNumeroPiece("ID123456");
        recensementDTO.setAgentId("agent-joseph");
    }

    @Test
    void createRecensement_shouldCreateContribuableAndQRCode() {
        when(contribuableRepository.existsByTelephone("+243812345678")).thenReturn(false);
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));
        when(contribuableRepository.save(any(Contribuable.class))).thenAnswer(inv -> {
            Contribuable c = inv.getArgument(0);
            c.setId(10L);
            return c;
        });
        when(qrCodeContribuableService.generateQRCodeWithCode(anyLong(), anyString()))
                .thenReturn(new QRCodeContribuableDTO());

        RecensementDTO result = recensementService.createRecensement(recensementDTO);

        assertNotNull(result);
        assertEquals("Mwamba", result.getNom());
        assertEquals("Augustin", result.getPrenoms());
        assertEquals("+243812345678", result.getTelephone());
        assertEquals("personne_physique", result.getType());
        assertEquals("Commerçant", result.getActivite());
        assertNotNull(result.getNumeroContribuable());
        assertNotNull(result.getQrCode());
        verify(contribuableRepository, atLeast(2)).save(any(Contribuable.class));
        verify(qrCodeContribuableService).generateQRCodeWithCode(eq(10L), anyString());
    }

    @Test
    void createRecensement_shouldThrowConflict_whenTelephoneAlreadyExists() {
        when(contribuableRepository.existsByTelephone("+243812345678")).thenReturn(true);

        assertThrows(ConflictException.class, () -> recensementService.createRecensement(recensementDTO));
        verify(contribuableRepository, never()).save(any());
        verify(qrCodeContribuableService, never()).generateQRCodeWithCode(anyLong(), anyString());
    }

    @Test
    void createRecensement_shouldThrowNotFound_whenZoneDoesNotExist() {
        when(contribuableRepository.existsByTelephone("+243812345678")).thenReturn(false);
        when(zoneRepository.findById(99L)).thenReturn(Optional.empty());

        recensementDTO.setZoneId(99L);
        assertThrows(NotFoundException.class, () -> recensementService.createRecensement(recensementDTO));
    }

    @Test
    void updateRecensement_shouldUpdateFields() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));
        when(contribuableRepository.save(any(Contribuable.class))).thenReturn(contribuable);
        when(qrCodeContribuableService.getActiveQRCode(10L)).thenReturn(Optional.empty());

        recensementDTO.setNom("Kabasele");
        RecensementDTO result = recensementService.updateRecensement(10L, recensementDTO);

        assertNotNull(result);
        assertEquals("Kabasele", contribuable.getNom());
    }

    @Test
    void updateRecensement_shouldThrowNotFound_whenContribuableDoesNotExist() {
        when(contribuableRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> recensementService.updateRecensement(99L, recensementDTO));
    }

    @Test
    void findById_shouldReturnDTO() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));
        when(qrCodeContribuableService.getActiveQRCode(10L)).thenReturn(Optional.empty());

        RecensementDTO result = recensementService.findById(10L);

        assertNotNull(result);
        assertEquals("Mwamba", result.getNom());
        assertEquals(1L, result.getZoneId());
    }

    @Test
    void findById_shouldThrowNotFound_whenContribuableDoesNotExist() {
        when(contribuableRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> recensementService.findById(99L));
    }

    @Test
    void findAll_shouldReturnList() {
        when(contribuableRepository.findAll()).thenReturn(Arrays.asList(contribuable));
        when(qrCodeContribuableService.getActiveQRCode(anyLong())).thenReturn(Optional.empty());

        List<RecensementDTO> result = recensementService.findAll();

        assertEquals(1, result.size());
        assertEquals("Mwamba", result.get(0).getNom());
    }

    @Test
    void searchContribuables_shouldReturnResults_byTelephone() {
        when(contribuableRepository.searchByNomPrenomOrTelephone("+243812345678"))
                .thenReturn(Arrays.asList(contribuable));
        when(qrCodeContribuableService.getActiveQRCode(anyLong())).thenReturn(Optional.empty());

        List<RecensementDTO> result = recensementService.searchContribuables(
                null, "+243812345678", null, null, null, 20, 0);

        assertEquals(1, result.size());
        assertEquals("Mwamba", result.get(0).getNom());
    }

    @Test
    void searchContribuables_shouldReturnResults_byQuery() {
        when(contribuableRepository.searchByNomPrenomOrTelephone("Mwamba"))
                .thenReturn(Arrays.asList(contribuable));
        when(qrCodeContribuableService.getActiveQRCode(anyLong())).thenReturn(Optional.empty());

        List<RecensementDTO> result = recensementService.searchContribuables(
                "Mwamba", null, null, null, null, 20, 0);

        assertEquals(1, result.size());
    }

    @Test
    void searchContribuables_shouldReturnResults_byZone() {
        when(contribuableRepository.findByZoneId(1L))
                .thenReturn(Arrays.asList(contribuable));
        when(qrCodeContribuableService.getActiveQRCode(anyLong())).thenReturn(Optional.empty());

        List<RecensementDTO> result = recensementService.searchContribuables(
                null, null, null, null, 1L, 20, 0);

        assertEquals(1, result.size());
    }

    @Test
    void getStatistics_shouldReturnCorrectCounts() {
        when(contribuableRepository.count()).thenReturn(50L);
        when(contribuableRepository.countByCreatedAtBetween(any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(5L);
        when(contribuableRepository.countByUpdatedAtBetween(any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(3L);
        when(contribuableRepository.countByZone()).thenReturn(Arrays.asList(new Object[][]{{"Marché central", 20L}}));

        RecensementStatsDTO stats = recensementService.getStatistics();

        assertNotNull(stats);
        assertEquals(50L, stats.getTotalContribuables());
        assertEquals(5L, stats.getCreesAujourdhui());
        assertEquals(3L, stats.getMisAJourAujourdhui());
        assertEquals(100.0, stats.getTauxSynchronisation());
        assertNotNull(stats.getRepartitionParZone());
        assertEquals(1, stats.getRepartitionParZone().size());
        assertEquals(20L, stats.getRepartitionParZone().get("Marché central"));
    }

    @Test
    void getStatistics_shouldHandleZeroContribuables() {
        when(contribuableRepository.count()).thenReturn(0L);
        when(contribuableRepository.countByCreatedAtBetween(any(), any())).thenReturn(0L);
        when(contribuableRepository.countByUpdatedAtBetween(any(), any())).thenReturn(0L);
        when(contribuableRepository.countByZone()).thenReturn(List.of(new Object[0][]));

        RecensementStatsDTO stats = recensementService.getStatistics();

        assertEquals(0L, stats.getTotalContribuables());
        assertEquals(0.0, stats.getTauxSynchronisation());
    }

    @Test
    void delete_shouldDeleteContribuable() {
        when(contribuableRepository.findById(10L)).thenReturn(Optional.of(contribuable));

        recensementService.delete(10L);

        verify(contribuableRepository).delete(contribuable);
    }

    @Test
    void delete_shouldThrowNotFound_whenContribuableDoesNotExist() {
        when(contribuableRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> recensementService.delete(99L));
        verify(contribuableRepository, never()).delete(any(Contribuable.class));
    }
}
