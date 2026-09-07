package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.TransactionDTO;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Transaction;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.TransactionRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private AgentRepository agentRepository;

    @Mock
    private ContribuableRepository contribuableRepository;

    @Mock
    private ZoneRepository zoneRepository;

    @InjectMocks
    private TransactionService transactionService;

    private Agents agent;
    private Contribuable contribuable;
    private Zone zone;
    private Transaction transaction;

    @BeforeEach
    void setUp() {
        agent = new Agents();
        agent.setId(1L);
        agent.setNom("Doe");
        agent.setPrenom("John");

        contribuable = new Contribuable();
        contribuable.setId(1L);
        contribuable.setNom("Smith");
        contribuable.setPrenom("Jane");

        zone = new Zone();
        zone.setId(1L);
        zone.setNom("Zone A");

        transaction = new Transaction();
        transaction.setId(1L);
        transaction.setNumeroRecu("TAX-20260727-0001");
        transaction.setMontant(new BigDecimal("5000.00"));
        transaction.setContribuable(contribuable);
        transaction.setAgent(agent);
        transaction.setZone(zone);
        transaction.setModePaiement(ModePaiement.ESPECE);
        transaction.setStatut(StatutTransaction.VALIDEE);
        transaction.setOffline(false);
        transaction.setDateCreation(LocalDateTime.now());
        transaction.setHashTransaction("abc123");
    }

    @Test
    void createTransaction_shouldSucceed_whenAllEntitiesExist() {
        TransactionDTO dto = new TransactionDTO();
        dto.setMontant(new BigDecimal("5000.00"));
        dto.setContribuableId(1L);
        dto.setAgentId(1L);
        dto.setZoneId(1L);
        dto.setModePaiement(ModePaiement.ESPECE);

        when(agentRepository.findById(1L)).thenReturn(Optional.of(agent));
        when(contribuableRepository.findById(1L)).thenReturn(Optional.of(contribuable));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));
        when(transactionRepository.save(any(Transaction.class))).thenReturn(transaction);

        TransactionDTO result = transactionService.createTransaction(dto);

        assertNotNull(result);
        assertEquals(new BigDecimal("5000.00"), result.getMontant());
        assertEquals("TAX-20260727-0001", result.getNumeroRecu());
        verify(transactionRepository, times(2)).save(any(Transaction.class));
    }

    @Test
    void createTransaction_shouldThrowNotFound_whenAgentDoesNotExist() {
        TransactionDTO dto = new TransactionDTO();
        dto.setMontant(new BigDecimal("5000.00"));
        dto.setContribuableId(1L);
        dto.setAgentId(999L);
        dto.setZoneId(1L);
        dto.setModePaiement(ModePaiement.ESPECE);

        when(agentRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> transactionService.createTransaction(dto));
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void getTransactionById_shouldReturnDTO_whenTransactionExists() {
        when(transactionRepository.findById(1L)).thenReturn(Optional.of(transaction));

        Optional<TransactionDTO> result = transactionService.getTransactionById(1L);

        assertTrue(result.isPresent());
        assertEquals(1L, result.get().getId());
        assertEquals("TAX-20260727-0001", result.get().getNumeroRecu());
    }

    @Test
    void getTransactionById_shouldReturnEmpty_whenTransactionDoesNotExist() {
        when(transactionRepository.findById(999L)).thenReturn(Optional.empty());

        Optional<TransactionDTO> result = transactionService.getTransactionById(999L);

        assertTrue(result.isEmpty());
    }

    @Test
    void synchronizeTransaction_shouldSucceed_whenTransactionIsOffline() {
        transaction.setOffline(true);
        when(transactionRepository.findById(1L)).thenReturn(Optional.of(transaction));
        when(transactionRepository.save(any(Transaction.class))).thenReturn(transaction);

        TransactionDTO result = transactionService.synchronizeTransaction(1L);

        assertNotNull(result);
        verify(transactionRepository).save(any(Transaction.class));
    }

    @Test
    void synchronizeTransaction_shouldThrowInvalidOperation_whenTransactionIsNotOffline() {
        transaction.setOffline(false);
        when(transactionRepository.findById(1L)).thenReturn(Optional.of(transaction));

        assertThrows(InvalidOperationException.class, () -> transactionService.synchronizeTransaction(1L));
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void synchronizeTransaction_shouldThrowNotFound_whenTransactionDoesNotExist() {
        when(transactionRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> transactionService.synchronizeTransaction(999L));
    }

    @Test
    void getTransactionsByAgent_shouldReturnList() {
        Pageable pageable = PageRequest.of(0, 1000);
        Page<Transaction> page = new PageImpl<>(List.of(transaction));
        when(transactionRepository.findByAgentId(1L, pageable)).thenReturn(page);

        List<TransactionDTO> result = transactionService.getTransactionsByAgent(1L);

        assertEquals(1, result.size());
        assertEquals("TAX-20260727-0001", result.get(0).getNumeroRecu());
    }

    @Test
    void filterTransactions_shouldUseSpecification() {
        Pageable pageable = PageRequest.of(0, 20);
        Page<Transaction> page = new PageImpl<>(List.of(transaction));
        when(transactionRepository.findAll(any(Specification.class), any(Pageable.class))).thenReturn(page);

        Page<TransactionDTO> result = transactionService.filterTransactions(
                LocalDateTime.now().minusDays(1), LocalDateTime.now(), 1L, "ESPECE", StatutTransaction.VALIDEE, 0, 20);

        assertEquals(1, result.getTotalElements());
        verify(transactionRepository).findAll(any(Specification.class), eq(pageable));
    }

    @Test
    void countOfflineTransactions_shouldReturnCount() {
        when(transactionRepository.countOfflineTransactions()).thenReturn(5L);

        Long result = transactionService.countOfflineTransactions();

        assertEquals(5L, result);
    }

    @Test
    void exportTransactions_shouldReturnCsvBytes() {
        when(transactionRepository.findAll(any(Specification.class))).thenReturn(Arrays.asList(transaction));

        byte[] result = transactionService.exportTransactions("csv", null, null, null, null);

        assertNotNull(result);
        String csv = new String(result);
        assertTrue(csv.contains("NumeroRecu,Montant"));
        assertTrue(csv.contains("TAX-20260727-0001"));
    }
}
