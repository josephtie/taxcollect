package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.dto.TransactionDTO;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.models.enums.StatutPayment;
import com.nectuxingenieries.collect.tax.repositories.TransactionRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.repositories.TaxeCollectRepository;
import com.nectuxingenieries.collect.tax.utils.ReceiptNumberGenerator;
import com.nectuxingenieries.collect.tax.utils.TransactionHashUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private AgentRepository agentRepository;

    @Autowired
    private ContribuableRepository contribuableRepository;

    @Autowired
    private ZoneRepository zoneRepository;

    @Autowired
    private TaxeCollectRepository taxeCollectRepository;

    // Récupérer toutes les transactions (non paginé - pour compatibilité)
    @Transactional(readOnly = true)
    public List<TransactionDTO> getAllTransactions() {
        return transactionRepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Récupérer toutes les transactions (paginé)
    @Transactional(readOnly = true)
    public Page<TransactionDTO> getAllTransactions(Pageable pageable) {
        Page<Transaction> transactionPage = transactionRepository.findAll(pageable);
        return transactionPage.map(this::convertToDTO);
    }

    public TransactionDTO createTransaction(TransactionDTO transactionDTO) {
        // Validation des entités
        Agents agent = agentRepository.findById(transactionDTO.getAgentId())
                .orElseThrow(() -> new NotFoundException("Agent", transactionDTO.getAgentId()));

        Contribuable contribuable = contribuableRepository.findById(transactionDTO.getContribuableId())
                .orElseThrow(() -> new NotFoundException("Contribuable", transactionDTO.getContribuableId()));

        Zone zone = zoneRepository.findById(transactionDTO.getZoneId())
                .orElseThrow(() -> new NotFoundException("Zone", transactionDTO.getZoneId()));

        // Création de la transaction
        Transaction transaction = new Transaction();
        transaction.setMontant(transactionDTO.getMontant());
        transaction.setContribuable(contribuable);
        transaction.setAgent(agent);
        transaction.setZone(zone);
        transaction.setModePaiement(transactionDTO.getModePaiement());
        transaction.setReferencePaiement(transactionDTO.getReferencePaiement());
        transaction.setLatitude(transactionDTO.getLatitude());
        transaction.setLongitude(transactionDTO.getLongitude());
        transaction.setAdresseCollecte(transactionDTO.getAdresseCollecte());
        transaction.setOffline(transactionDTO.getOffline() != null ? transactionDTO.getOffline() : false);
        transaction.setDateCreation(LocalDateTime.now());

        // Lier la transaction à une TaxeCollect si fournie
        if (transactionDTO.getTaxeCollectId() != null) {
            TaxeCollect taxeCollect = taxeCollectRepository.findById(transactionDTO.getTaxeCollectId())
                    .orElseThrow(() -> new NotFoundException("TaxeCollect", transactionDTO.getTaxeCollectId()));
            transaction.setTaxeCollect(taxeCollect);
        }

        // Génération du numéro de reçu unique
        String numeroRecu = ReceiptNumberGenerator.generateReceiptNumber();
        transaction.setNumeroRecu(numeroRecu);

        // Génération du hash de transaction pour la sécurité
        String hashTransaction = TransactionHashUtil.generateTransactionHash(
                null, // ID sera généré après la sauvegarde
                transactionDTO.getMontant(),
                transactionDTO.getContribuableId(),
                transactionDTO.getAgentId(),
                transaction.getDateCreation()
        );
        transaction.setHashTransaction(hashTransaction);

        // Sauvegarde de la transaction
        Transaction savedTransaction = transactionRepository.save(transaction);

        // Mise à jour du hash avec l'ID réel
        String finalHash = TransactionHashUtil.generateTransactionHash(
                savedTransaction.getId(),
                savedTransaction.getMontant(),
                savedTransaction.getContribuable().getId(),
                savedTransaction.getAgent().getId(),
                savedTransaction.getDateCreation()
        );
        savedTransaction.setHashTransaction(finalHash);
        savedTransaction = transactionRepository.save(savedTransaction);

        // Mise à jour de la TaxeCollect liée
        if (savedTransaction.getTaxeCollect() != null) {
            TaxeCollect taxeCollect = savedTransaction.getTaxeCollect();
            taxeCollect.setPaye(true);
            taxeCollect.setStatut(StatutPayment.PAYE);
            taxeCollect.setDatePaiement(savedTransaction.getDateCreation().toLocalDate());
            taxeCollect.setModePaiement(savedTransaction.getModePaiement());
            taxeCollect.setNumeroRecu(savedTransaction.getNumeroRecu());
            taxeCollectRepository.save(taxeCollect);
        }

        return convertToDTO(savedTransaction);
    }

    @Transactional(readOnly = true)
    public Optional<TransactionDTO> getTransactionById(Long id) {
        return transactionRepository.findById(id)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public Optional<TransactionDTO> getTransactionByNumeroRecu(String numeroRecu) {
        return transactionRepository.findByNumeroRecu(numeroRecu)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public List<TransactionDTO> getTransactionsByAgent(Long agentId) {
        Pageable pageable = PageRequest.of(0, 1000); // Limite à 1000 résultats
        return transactionRepository.findByAgentId(agentId, pageable)
                .getContent()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<TransactionDTO> getTransactionsByAgentAndDateRange(Long agentId, LocalDateTime debut, LocalDateTime fin) {
        return transactionRepository.findTransactionsByAgentAndDateRange(agentId, debut, fin)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TransactionDTO synchronizeTransaction(Long transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new NotFoundException("Transaction", transactionId));

        if (!transaction.getOffline()) {
            throw new InvalidOperationException("Cette transaction n'est pas en mode hors-ligne");
        }

        transaction.setOffline(false);
        transaction.setStatut(StatutTransaction.SYNCHRONISEE);
        transaction.setDateSynchronisation(LocalDateTime.now());

        Transaction savedTransaction = transactionRepository.save(transaction);
        return convertToDTO(savedTransaction);
    }

    public List<TransactionDTO> synchronizeOfflineTransactions() {
        List<Transaction> offlineTransactions = transactionRepository.findByOfflineTrue();
        
        return offlineTransactions.stream()
                .map(transaction -> {
                    transaction.setOffline(false);
                    transaction.setStatut(StatutTransaction.SYNCHRONISEE);
                    transaction.setDateSynchronisation(LocalDateTime.now());
                    return transactionRepository.save(transaction);
                })
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TransactionDTO updateTransactionStatus(Long transactionId, StatutTransaction newStatus) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new NotFoundException("Transaction", transactionId));

        transaction.setStatut(newStatus);
        Transaction savedTransaction = transactionRepository.save(transaction);
        return convertToDTO(savedTransaction);
    }

    @Transactional(readOnly = true)
    public boolean verifyTransactionHash(Long transactionId, String hashToVerify) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new NotFoundException("Transaction", transactionId));

        TransactionHashUtil.TransactionData data = new TransactionHashUtil.TransactionData(
                transaction.getId(),
                transaction.getMontant(),
                transaction.getContribuable().getId(),
                transaction.getAgent().getId(),
                transaction.getDateCreation()
        );

        return TransactionHashUtil.verifyTransactionHash(hashToVerify, data);
    }

    @Transactional(readOnly = true)
    public Long countOfflineTransactions() {
        return transactionRepository.countOfflineTransactions();
    }

    private TransactionDTO convertToDTO(Transaction transaction) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(transaction.getId());
        dto.setNumeroRecu(transaction.getNumeroRecu());
        dto.setMontant(transaction.getMontant());
        dto.setContribuableId(transaction.getContribuable().getId());
        dto.setAgentId(transaction.getAgent().getId());
        dto.setZoneId(transaction.getZone().getId());
        dto.setModePaiement(transaction.getModePaiement());
        dto.setStatut(transaction.getStatut());
        dto.setReferencePaiement(transaction.getReferencePaiement());
        dto.setHashTransaction(transaction.getHashTransaction());
        dto.setLatitude(transaction.getLatitude());
        dto.setLongitude(transaction.getLongitude());
        dto.setAdresseCollecte(transaction.getAdresseCollecte());
        dto.setOffline(transaction.getOffline());
        dto.setDateSynchronisation(transaction.getDateSynchronisation());
        dto.setDateCreation(transaction.getDateCreation());

        // Informations additionnelles
        dto.setContribuableNom(transaction.getContribuable().getNom());
        dto.setContribuablePrenom(transaction.getContribuable().getPrenom());
        dto.setAgentNom(transaction.getAgent().getNom());
        dto.setAgentPrenom(transaction.getAgent().getPrenom());
        dto.setZoneNom(transaction.getZone().getNom());

        if (transaction.getTaxeCollect() != null) {
            dto.setTaxeCollectId(transaction.getTaxeCollect().getId());
        }

        return dto;
    }

    public List<TransactionDTO> getTransactionsByZone(Long zoneId) {
        Pageable pageable = PageRequest.of(0, 1000); // Limite à 1000 résultats
        return transactionRepository.findByZoneId(zoneId, pageable)
                .getContent()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TransactionDTO> getTransactionsByContribuable(Long contribuableId) {
        Pageable pageable = PageRequest.of(0, 1000); // Limite à 1000 résultats
        return transactionRepository.findByContribuableId(contribuableId, pageable)
                .getContent()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // Méthodes manquantes ajoutées
    @Transactional(readOnly = true)
    public Page<TransactionDTO> filterTransactions(LocalDateTime debut, LocalDateTime fin, Long agentId, String paymentMethod, StatutTransaction statut, Integer page, Integer size) {
        int pageSize = size != null ? size : 20;
        int pageNumber = page != null ? page : 0;
        Pageable pageable = PageRequest.of(pageNumber, pageSize);
        
        Specification<Transaction> spec = TransactionSpecifications.withFilters(debut, fin, agentId, paymentMethod, statut);
        return transactionRepository.findAll(spec, pageable).map(this::convertToDTO);
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getTransactionStats(LocalDateTime debut, LocalDateTime fin) {
        Map<String, Object> stats = new java.util.HashMap<>();
        
        // Statistiques de base via requêtes SQL agrégées
        long totalTransactions = debut != null || fin != null
                ? transactionRepository.countByDateRange(debut, fin)
                : transactionRepository.count();
        stats.put("totalTransactions", totalTransactions);
        
        // Montant total via SUM SQL
        BigDecimal montantTotal = (debut != null || fin != null)
                ? transactionRepository.sumMontantByDateRange(debut, fin)
                : transactionRepository.sumMontantAll();
        stats.put("montantTotal", montantTotal != null ? montantTotal : BigDecimal.ZERO);
        
        // Montant moyen
        BigDecimal montantMoyen = (totalTransactions > 0 && montantTotal != null)
                ? montantTotal.divide(BigDecimal.valueOf(totalTransactions), 2, java.math.RoundingMode.HALF_UP)
                : BigDecimal.ZERO;
        stats.put("montantMoyen", montantMoyen);
        
        // Répartition par mode de paiement via GROUP BY SQL
        Map<String, Long> repartitionPaiement = new java.util.HashMap<>();
        if (debut != null || fin != null) {
            List<Object[]> paiementResults = transactionRepository.countByModePaiementAndDateRange(debut, fin);
            for (Object[] row : paiementResults) {
                repartitionPaiement.put(((ModePaiement) row[0]).name(), (Long) row[1]);
            }
        } else {
            List<Object[]> paiementResults = transactionRepository.countByModePaiementAll();
            for (Object[] row : paiementResults) {
                repartitionPaiement.put(((ModePaiement) row[0]).name(), (Long) row[1]);
            }
        }
        stats.put("repartitionPaiement", repartitionPaiement);
        
        // Répartition par statut via GROUP BY SQL
        Map<String, Long> repartitionStatut = new java.util.HashMap<>();
        if (debut != null || fin != null) {
            List<Object[]> statutResults = transactionRepository.countByStatutAndDateRange(debut, fin);
            for (Object[] row : statutResults) {
                repartitionStatut.put(((StatutTransaction) row[0]).name(), (Long) row[1]);
            }
        } else {
            List<Object[]> statutResults = transactionRepository.countByStatutAll();
            for (Object[] row : statutResults) {
                repartitionStatut.put(((StatutTransaction) row[0]).name(), (Long) row[1]);
            }
        }
        stats.put("repartitionStatut", repartitionStatut);
        
        // Transactions hors-ligne
        stats.put("transactionsOffline", transactionRepository.countOfflineTransactions());
        
        // Période
        stats.put("startDate", debut);
        stats.put("endDate", fin);
        
        return stats;
    }
    
    @Transactional(readOnly = true)
    public byte[] exportTransactions(String format, LocalDateTime debut, LocalDateTime fin, Long agentId, String paymentMethod) {
        Specification<Transaction> spec = TransactionSpecifications.withFilters(debut, fin, agentId, paymentMethod, null);
        List<Transaction> transactions = transactionRepository.findAll(spec);
        
        if ("xlsx".equalsIgnoreCase(format)) {
            return exportToXlsx(transactions);
        } else {
            return exportToCsv(transactions);
        }
    }
    
    private byte[] exportToCsv(List<Transaction> transactions) {
        StringBuilder sb = new StringBuilder();
        sb.append("NumeroRecu,Montant,Agent,Contribuable,ModePaiement,Statut,DateCreation\n");
        
        for (Transaction transaction : transactions) {
            sb.append(String.format("%s,%s,%s %s,%s %s,%s,%s,%s\n",
                    transaction.getNumeroRecu(),
                    transaction.getMontant().toPlainString(),
                    transaction.getAgent().getNom(),
                    transaction.getAgent().getPrenom(),
                    transaction.getContribuable().getNom(),
                    transaction.getContribuable().getPrenom(),
                    transaction.getModePaiement().name(),
                    transaction.getStatut().name(),
                    transaction.getDateCreation()
            ));
        }
        
        return sb.toString().getBytes();
    }
    
    private byte[] exportToXlsx(List<Transaction> transactions) {
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Transactions");
            
            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            
            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            String[] headers = {"NumeroRecu", "Montant", "Agent", "Contribuable", "ModePaiement", "Statut", "DateCreation"};
            for (int i = 0; i < headers.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4000);
            }
            
            int rowIdx = 1;
            for (Transaction t : transactions) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(t.getNumeroRecu());
                row.createCell(1).setCellValue(t.getMontant().doubleValue());
                row.createCell(2).setCellValue(t.getAgent().getNom() + " " + t.getAgent().getPrenom());
                row.createCell(3).setCellValue(t.getContribuable().getNom() + " " + t.getContribuable().getPrenom());
                row.createCell(4).setCellValue(t.getModePaiement().name());
                row.createCell(5).setCellValue(t.getStatut().name());
                row.createCell(6).setCellValue(t.getDateCreation().toString());
            }
            
            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            workbook.write(baos);
            return baos.toByteArray();
        } catch (java.io.IOException e) {
            throw new RuntimeException("Erreur lors de la génération du fichier Excel", e);
        }
    }
}
