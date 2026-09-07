package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.enums.StatutPayment;
import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
import com.nectuxingenieries.collect.tax.models.enums.TypeCalcul;
import com.nectuxingenieries.collect.tax.models.mappers.TaxeCollectMapper;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.TaxeCollectRepository;
import com.nectuxingenieries.collect.tax.repositories.TaxeRepository;
import com.nectuxingenieries.collect.tax.services.impl.AssessmentServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AssessmentServiceTest {

    @Mock
    private TaxeRepository taxeRepository;

    @Mock
    private TaxeCollectRepository taxeCollectRepository;

    @Mock
    private ContribuableRepository contribuableRepository;

    @Mock
    private TaxeCollectMapper taxeCollectMapper;

    @InjectMocks
    private AssessmentServiceImpl assessmentService;

    private Taxe taxe;
    private Contribuable contribuable;
    private Zone zone;

    @BeforeEach
    void setUp() {
        zone = new Zone();
        zone.setId(1L);
        zone.setNom("Zone Test");

        contribuable = new Contribuable();
        contribuable.setId(1L);
        contribuable.setNom("Doe");
        contribuable.setPrenom("John");
        contribuable.setZone(zone);
        contribuable.setBaseImposable(new BigDecimal("1000000"));

        taxe = new Taxe();
        taxe.setId(1L);
        taxe.setNom("Taxe Test");
        taxe.setPeriodicite(TaxePeriodicite.MENSUELLE);
        taxe.setTypeCalcul(TypeCalcul.MONTANT);
        taxe.setMontantFixe(new BigDecimal("5000"));
        taxe.setCategorie(TaxeCategorie.AUTRE);
    }

    @Test
    void generateForPeriod_shouldCreateAssessmentsWithReferenceAndTaxe() {
        when(taxeRepository.findById(1L)).thenReturn(Optional.of(taxe));
        when(contribuableRepository.findActiveContribuables()).thenReturn(Arrays.asList(contribuable));
        when(taxeCollectRepository.findByContribuableAndTaxeAndPeriodStart(1L, "Taxe Test", LocalDate.of(2026, 1, 1)))
                .thenReturn(Optional.empty());
        when(taxeCollectRepository.save(any(TaxeCollect.class))).thenAnswer(inv -> inv.getArgument(0));

        int result = assessmentService.generateForPeriod(1L, LocalDate.of(2026, 1, 15));

        assertEquals(1, result);

        ArgumentCaptor<TaxeCollect> captor = ArgumentCaptor.forClass(TaxeCollect.class);
        verify(taxeCollectRepository).save(captor.capture());

        TaxeCollect saved = captor.getValue();
        assertNotNull(saved.getReference());
        assertTrue(saved.getReference().startsWith("AVIS-TAX-"));
        assertEquals("Taxe Test", saved.getTaxType());
        assertEquals(taxe, saved.getTaxe());
        assertEquals(StatutPayment.IMPAYE, saved.getStatut());
        assertEquals(new BigDecimal("5000"), saved.getMontant());
    }

    @Test
    void generateForPeriod_shouldSkipExistingAssessments() {
        TaxeCollect existing = new TaxeCollect();
        existing.setContribuable(contribuable);
        existing.setTaxType("Taxe Test");
        existing.setPeriodStart(LocalDate.of(2026, 1, 1));

        when(taxeRepository.findById(1L)).thenReturn(Optional.of(taxe));
        when(contribuableRepository.findActiveContribuables()).thenReturn(Arrays.asList(contribuable));
        when(taxeCollectRepository.findByContribuableAndTaxeAndPeriodStart(1L, "Taxe Test", LocalDate.of(2026, 1, 1)))
                .thenReturn(Optional.of(existing));

        int result = assessmentService.generateForPeriod(1L, LocalDate.of(2026, 1, 15));

        assertEquals(0, result);
        verify(taxeCollectRepository, never()).save(any());
    }

    @Test
    void generateForPeriod_shouldThrowWhenTaxeNotFound() {
        when(taxeRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            assessmentService.generateForPeriod(999L, LocalDate.now());
        });
    }

    @Test
    void findAssessmentsByPeriod_shouldReturnFilteredResults() {
        TaxeCollect tc1 = new TaxeCollect();
        tc1.setPeriodStart(LocalDate.of(2026, 1, 1));
        tc1.setReference("AVIS-001");
        tc1.setTaxType("Taxe Test");

        TaxeCollect tc2 = new TaxeCollect();
        tc2.setPeriodStart(LocalDate.of(2026, 3, 1));
        tc2.setReference("AVIS-002");
        tc2.setTaxType("Taxe Test");

        TaxeCollectDto dto1 = new TaxeCollectDto();
        dto1.setReference("AVIS-001");
        TaxeCollectDto dto2 = new TaxeCollectDto();
        dto2.setReference("AVIS-002");

        when(taxeCollectRepository.findAll()).thenReturn(Arrays.asList(tc1, tc2));
        when(taxeCollectMapper.toDto(tc1)).thenReturn(dto1);

        List<TaxeCollectDto> result = assessmentService.findAssessmentsByPeriod(
                LocalDate.of(2026, 1, 1), LocalDate.of(2026, 2, 28));

        assertEquals(1, result.size());
        assertEquals("AVIS-001", result.get(0).getReference());
    }
}
