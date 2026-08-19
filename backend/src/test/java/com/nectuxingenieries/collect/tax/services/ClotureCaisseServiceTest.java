package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.ClotureCaisseDTO;
import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.ClotureCaisse;
import com.nectuxingenieries.collect.tax.models.Transaction;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ClotureCaisseRepository;
import com.nectuxingenieries.collect.tax.repositories.TransactionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ClotureCaisseServiceTest {

    @Mock
    private ClotureCaisseRepository clotureCaisseRepository;

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private AgentRepository agentRepository;

    @InjectMocks
    private ClotureCaisseService clotureCaisseService;

    private Agents agent;
    private ClotureCaisse clotureCaisse;
    private Transaction transaction;

    @BeforeEach
    void setUp() {
        agent = new Agents();
        agent.setId(1L);
        agent.setNom("Doe");
        agent.setPrenom("John");

        clotureCaisse = new ClotureCaisse();
        clotureCaisse.setId(1L);
        clotureCaisse.setAgent(agent);
        clotureCaisse.setDateCloture(LocalDate.now());
        clotureCaisse.setMontantTotalEspece(new BigDecimal("10000.00"));
        clotureCaisse.setMontantTotalMobileMoney(new BigDecimal("5000.00"));
        clotureCaisse.setMontantTotal(new BigDecimal("15000.00"));
        clotureCaisse.setNombreTransactions(2);
        clotureCaisse.setStatut(StatutCloture.EN_COURS);

        transaction = new Transaction();
        transaction.setId(1L);
        transaction.setMontant(new BigDecimal("10000.00"));
        transaction.setAgent(agent);
        transaction.setModePaiement(ModePaiement.ESPECE);
        transaction.setStatut(StatutTransaction.VALIDEE);
        transaction.setDateCreation(LocalDateTime.now());
    }

    @Test
    void initierClotureCaisse_shouldSucceed_whenNoExistingCloture() {
        LocalDate date = LocalDate.now();
        when(clotureCaisseRepository.existsByAgentIdAndDateCloture(1L, date)).thenReturn(false);
        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(transactionRepository.findTransactionsByAgentAndDateRange(eq(1L), any(), any()))
                .thenReturn(List.of(transaction));
        when(clotureCaisseRepository.save(any(ClotureCaisse.class))).thenReturn(clotureCaisse);
        when(transactionRepository.save(any(Transaction.class))).thenReturn(transaction);

        ClotureCaisseDTO result = clotureCaisseService.initierClotureCaisse(1L, date);

        assertNotNull(result);
        assertEquals(new BigDecimal("10000.00"), result.getMontantTotalEspece());
        assertEquals(new BigDecimal("15000.00"), result.getMontantTotal());
        assertEquals(2, result.getNombreTransactions());
    }

    @Test
    void initierClotureCaisse_shouldThrowConflict_whenClotureAlreadyExists() {
        LocalDate date = LocalDate.now();
        when(clotureCaisseRepository.existsByAgentIdAndDateCloture(1L, date)).thenReturn(true);

        assertThrows(ConflictException.class, () -> clotureCaisseService.initierClotureCaisse(1L, date));
        verify(clotureCaisseRepository, never()).save(any());
    }

    @Test
    void initierClotureCaisse_shouldThrowNotFound_whenAgentDoesNotExist() {
        LocalDate date = LocalDate.now();
        when(clotureCaisseRepository.existsByAgentIdAndDateCloture(999L, date)).thenReturn(false);
        when(agentRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> clotureCaisseService.initierClotureCaisse(999L, date));
    }

    @Test
    void soumettreClotureCaisse_shouldSucceed_whenStatutIsEnCours() {
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));
        when(clotureCaisseRepository.save(any(ClotureCaisse.class))).thenReturn(clotureCaisse);

        ClotureCaisseDTO result = clotureCaisseService.soumettreClotureCaisse(
                1L, new BigDecimal("14000.00"), "Commentaire test");

        assertNotNull(result);
        assertEquals(StatutCloture.SOUMISE, clotureCaisse.getStatut());
        assertEquals(new BigDecimal("14000.00"), clotureCaisse.getMontantDeclare());
    }

    @Test
    void soumettreClotureCaisse_shouldThrowInvalidOperation_whenStatutIsNotEnCours() {
        clotureCaisse.setStatut(StatutCloture.VALIDEE);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));

        assertThrows(InvalidOperationException.class, () ->
                clotureCaisseService.soumettreClotureCaisse(1L, BigDecimal.ZERO, "test"));
    }

    @Test
    void validerClotureCaisse_shouldSucceed_whenStatutIsSoumise() {
        clotureCaisse.setStatut(StatutCloture.SOUMISE);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));
        when(agentRepository.findById(2L)).thenReturn(Optional.of(agent));
        when(clotureCaisseRepository.save(any(ClotureCaisse.class))).thenReturn(clotureCaisse);

        ClotureCaisseDTO result = clotureCaisseService.validerClotureCaisse(1L, 2L, "Validé");

        assertNotNull(result);
        assertEquals(StatutCloture.VALIDEE, clotureCaisse.getStatut());
        assertNotNull(clotureCaisse.getDateValidationTresor());
    }

    @Test
    void validerClotureCaisse_shouldThrowInvalidOperation_whenStatutIsNotSoumise() {
        clotureCaisse.setStatut(StatutCloture.EN_COURS);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));

        assertThrows(InvalidOperationException.class, () ->
                clotureCaisseService.validerClotureCaisse(1L, 2L, "test"));
    }

    @Test
    void rejeterClotureCaisse_shouldSucceed_whenStatutIsSoumise() {
        clotureCaisse.setStatut(StatutCloture.SOUMISE);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));
        when(agentRepository.findById(2L)).thenReturn(Optional.of(agent));
        when(clotureCaisseRepository.save(any(ClotureCaisse.class))).thenReturn(clotureCaisse);

        ClotureCaisseDTO result = clotureCaisseService.rejeterClotureCaisse(1L, 2L, "Rejeté");

        assertNotNull(result);
        assertEquals(StatutCloture.REJETEE, clotureCaisse.getStatut());
    }

    @Test
    void confirmerDepotBanque_shouldSucceed_whenStatutIsValidee() {
        clotureCaisse.setStatut(StatutCloture.VALIDEE);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));
        when(clotureCaisseRepository.save(any(ClotureCaisse.class))).thenReturn(clotureCaisse);

        ClotureCaisseDTO result = clotureCaisseService.confirmerDepotBanque(
                1L, new BigDecimal("15000.00"), "REF-001");

        assertNotNull(result);
        assertEquals(StatutCloture.DEPOSEE, clotureCaisse.getStatut());
        assertEquals(new BigDecimal("15000.00"), clotureCaisse.getMontantDepose());
        assertEquals("REF-001", clotureCaisse.getReferenceDepotBanque());
    }

    @Test
    void confirmerDepotBanque_shouldThrowInvalidOperation_whenStatutIsNotValidee() {
        clotureCaisse.setStatut(StatutCloture.EN_COURS);
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));

        assertThrows(InvalidOperationException.class, () ->
                clotureCaisseService.confirmerDepotBanque(1L, BigDecimal.ZERO, "REF"));
    }

    @Test
    void getClotureCaisseById_shouldReturnDTO_whenExists() {
        when(clotureCaisseRepository.findById(1L)).thenReturn(Optional.of(clotureCaisse));

        Optional<ClotureCaisseDTO> result = clotureCaisseService.getClotureCaisseById(1L);

        assertTrue(result.isPresent());
        assertEquals(1L, result.get().getId());
    }

    @Test
    void getClotureCaisseById_shouldReturnEmpty_whenNotExists() {
        when(clotureCaisseRepository.findById(999L)).thenReturn(Optional.empty());

        Optional<ClotureCaisseDTO> result = clotureCaisseService.getClotureCaisseById(999L);

        assertTrue(result.isEmpty());
    }
}
