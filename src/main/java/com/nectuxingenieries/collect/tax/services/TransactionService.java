package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.dto.TransactionDTO;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.TransactionRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneCollecteRepository;
import com.nectuxingenieries.collect.tax.utils.ReceiptNumberGenerator;
import com.nectuxingenieries.collect.tax.utils.TransactionHashUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private ZoneCollecteRepository zoneCollecteRepository;

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
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));

        Contribuable contribuable = contribuableRepository.findById(transactionDTO.getContribuableId())
                .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));

        ZoneCollecte zone = zoneCollecteRepository.findById(transactionDTO.getZoneId())
                .orElseThrow(() -> new RuntimeException("Zone de collecte non trouvée"));

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
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

        if (!transaction.getOffline()) {
            throw new RuntimeException("Cette transaction n'est pas en mode hors-ligne");
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
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

        transaction.setStatut(newStatus);
        Transaction savedTransaction = transactionRepository.save(transaction);
        return convertToDTO(savedTransaction);
    }

    @Transactional(readOnly = true)
    public boolean verifyTransactionHash(Long transactionId, String hashToVerify) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

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
        // Pour l'instant, retourner une page vide
        // À implémenter avec les critères de filtrage appropriés
        int pageSize = size != null ? size : 20;
        int pageNumber = page != null ? page : 0;
        Pageable pageable = PageRequest.of(pageNumber, pageSize);
        
        // Implémentation basique - à améliorer avec les vrais critères
        List<Transaction> transactions = transactionRepository.findAll();
        
        // Filtrage basique (à améliorer avec Specifications)
        if (debut != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getDateCreation().isAfter(debut))
                    .collect(Collectors.toList());
        }
        if (fin != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getDateCreation().isBefore(fin))
                    .collect(Collectors.toList());
        }
        if (agentId != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getAgent().getId().equals(agentId))
                    .collect(Collectors.toList());
        }
        if (paymentMethod != null) {
            transactions = transactions.stream()
                    .filter(t -> paymentMethod.equals(t.getModePaiement().name()))
                    .collect(Collectors.toList());
        }
        if (statut != null) {
            transactions = transactions.stream()
                    .filter(t -> statut.equals(t.getStatut()))
                    .collect(Collectors.toList());
        }
        
        // Convertir en page
        int start = Math.min(pageNumber * pageSize, transactions.size());
        int end = Math.min(start + pageSize, transactions.size());
        List<Transaction> pageTransactions = transactions.subList(start, end);
        
        List<TransactionDTO> dtos = pageTransactions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return new org.springframework.data.domain.PageImpl<TransactionDTO>(
                dtos, 
                pageable, 
                transactions.size()
        );
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getTransactionStats(LocalDateTime debut, LocalDateTime fin) {
        Map<String, Object> stats = new java.util.HashMap<>();
        
        // Statistiques de base
        stats.put("totalTransactions", transactionRepository.count());
        
        // Calculer le montant total
        List<Transaction> allTransactions = transactionRepository.findAll();
        double montantTotal = allTransactions.stream()
                .mapToDouble(t -> t.getMontant().doubleValue())
                .sum();
        stats.put("montantTotal", montantTotal);
        
        // Montant moyen
        double montantMoyen = allTransactions.isEmpty() ? 0.0 : montantTotal / allTransactions.size();
        stats.put("montantMoyen", montantMoyen);
        
        // Répartition par mode de paiement
        Map<String, Long> repartitionPaiement = new java.util.HashMap<>();
        for (ModePaiement mode : ModePaiement.values()) {
            long count = allTransactions.stream()
                    .filter(t -> mode.equals(t.getModePaiement()))
                    .count();
            repartitionPaiement.put(mode.name(), count);
        }
        stats.put("repartitionPaiement", repartitionPaiement);
        
        // Répartition par statut
        Map<String, Long> repartitionStatut = new java.util.HashMap<>();
        for (StatutTransaction statut : StatutTransaction.values()) {
            long count = allTransactions.stream()
                    .filter(t -> statut.equals(t.getStatut()))
                    .count();
            repartitionStatut.put(statut.name(), count);
        }
        stats.put("repartitionStatut", repartitionStatut);
        
        // Transactions hors-ligne
        long offlineCount = allTransactions.stream()
                .filter(Transaction::getOffline)
                .count();
        stats.put("transactionsOffline", offlineCount);
        
        // Période
        stats.put("startDate", debut);
        stats.put("endDate", fin);
        
        return stats;
    }
    
    @Transactional(readOnly = true)
    public byte[] exportTransactions(String format, LocalDateTime debut, LocalDateTime fin, Long agentId, String paymentMethod) {
        // Pour l'instant, retourner un contenu CSV basique
        // À implémenter avec Apache POI pour Excel
        String content = "NumeroRecu,Montant,Agent,Contribuable,ModePaiement,Statut,DateCreation\n";
        
        List<Transaction> transactions = transactionRepository.findAll();
        
        // Filtrage basique
        if (debut != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getDateCreation().isAfter(debut))
                    .collect(Collectors.toList());
        }
        if (fin != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getDateCreation().isBefore(fin))
                    .collect(Collectors.toList());
        }
        if (agentId != null) {
            transactions = transactions.stream()
                    .filter(t -> t.getAgent().getId().equals(agentId))
                    .collect(Collectors.toList());
        }
        if (paymentMethod != null) {
            transactions = transactions.stream()
                    .filter(t -> paymentMethod.equals(t.getModePaiement().name()))
                    .collect(Collectors.toList());
        }
        
        for (Transaction transaction : transactions) {
            content += String.format("%s,%.2f,%s %s,%s %s,%s,%s\n",
                    transaction.getNumeroRecu(),
                    transaction.getMontant(),
                    transaction.getAgent().getNom(),
                    transaction.getAgent().getPrenom(),
                    transaction.getContribuable().getNom(),
                    transaction.getContribuable().getPrenom(),
                    transaction.getModePaiement().name(),
                    transaction.getStatut().name(),
                    transaction.getDateCreation()
            );
        }
        
        return content.getBytes();
    }
}
