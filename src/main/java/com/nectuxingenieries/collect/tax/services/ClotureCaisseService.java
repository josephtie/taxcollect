package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.dto.ClotureCaisseDTO;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import com.nectuxingenieries.collect.tax.repositories.ClotureCaisseRepository;
import com.nectuxingenieries.collect.tax.repositories.TransactionRepository;
import com.nectuxingenieries.collect.tax.repositories.AgentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ClotureCaisseService {

    @Autowired
    private ClotureCaisseRepository clotureCaisseRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private AgentRepository agentRepository;

    // Récupérer toutes les clôtures (non paginé - pour compatibilité)
    @Transactional(readOnly = true)
    public List<ClotureCaisseDTO> getAllClotures() {
        return clotureCaisseRepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Récupérer toutes les clôtures (paginé)
    @Transactional(readOnly = true)
    public Page<ClotureCaisseDTO> getAllClotures(Pageable pageable) {
        Page<ClotureCaisse> cloturePage = clotureCaisseRepository.findAll(pageable);
        return cloturePage.map(this::convertToDTO);
    }

    public ClotureCaisseDTO initierClotureCaisse(Long agentId, LocalDate dateCloture) {
        // Vérifier si une clôture existe déjà pour cet agent et cette date
        if (clotureCaisseRepository.existsByAgentIdAndDateCloture(agentId, dateCloture)) {
            throw new RuntimeException("Une clôture de caisse existe déjà pour cet agent à cette date");
        }

        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("Agent non trouvé"));

        // Récupérer les transactions du jour pour cet agent
        LocalDateTime debut = dateCloture.atStartOfDay();
        LocalDateTime fin = dateCloture.atTime(23, 59, 59);

        List<Transaction> transactionsDuJour = transactionRepository
                .findTransactionsByAgentAndDateRange(agentId, debut, fin);

        // Calculer les montants par mode de paiement
        BigDecimal montantTotalEspece = BigDecimal.ZERO;
        BigDecimal montantTotalMobileMoney = BigDecimal.ZERO;

        for (Transaction transaction : transactionsDuJour) {
            if (transaction.getStatut() == StatutTransaction.VALIDEE || 
                transaction.getStatut() == StatutTransaction.SYNCHRONISEE) {
                if (transaction.getModePaiement() == ModePaiement.ESPECE) {
                    montantTotalEspece = montantTotalEspece.add(BigDecimal.valueOf(transaction.getMontant()));
                } else if (transaction.getModePaiement() == ModePaiement.MOBILE_MONEY) {
                    montantTotalMobileMoney = montantTotalMobileMoney.add(BigDecimal.valueOf(transaction.getMontant()));
                }
            }
        }

        BigDecimal montantTotal = montantTotalEspece.add(montantTotalMobileMoney);

        // Créer la clôture de caisse
        ClotureCaisse clotureCaisse = new ClotureCaisse();
        clotureCaisse.setAgent(agent);
        clotureCaisse.setDateCloture(dateCloture);
        clotureCaisse.setMontantTotalEspece(montantTotalEspece);
        clotureCaisse.setMontantTotalMobileMoney(montantTotalMobileMoney);
        clotureCaisse.setMontantTotal(montantTotal);
        clotureCaisse.setNombreTransactions(transactionsDuJour.size());
        clotureCaisse.setStatut(StatutCloture.EN_COURS);

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);

        // Associer les transactions à la clôture
        for (Transaction transaction : transactionsDuJour) {
            transaction.setClotureCaisse(savedCloture);
            transactionRepository.save(transaction);
        }

        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO soumettreClotureCaisse(Long clotureId, BigDecimal montantDeclare, String commentaireAgent) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new RuntimeException("Clôture de caisse non trouvée"));

        if (clotureCaisse.getStatut() != StatutCloture.EN_COURS) {
            throw new RuntimeException("Cette clôture ne peut plus être modifiée");
        }

        clotureCaisse.setMontantDeclare(montantDeclare);
        clotureCaisse.setCommentaireAgent(commentaireAgent);
        clotureCaisse.setStatut(StatutCloture.SOUMISE);

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO validerClotureCaisse(Long clotureId, Long valideParId, String commentaireTresor) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new RuntimeException("Clôture de caisse non trouvée"));

        if (clotureCaisse.getStatut() != StatutCloture.SOUMISE) {
            throw new RuntimeException("Seules les clôtures soumises peuvent être validées");
        }

        Agents validePar = agentRepository.findById(valideParId)
                .orElseThrow(() -> new RuntimeException("Agent validateur non trouvé"));

        clotureCaisse.setStatut(StatutCloture.VALIDEE);
        clotureCaisse.setValidePar(validePar);
        clotureCaisse.setCommentaireTresor(commentaireTresor);
        clotureCaisse.setDateValidationTresor(LocalDateTime.now());

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO rejeterClotureCaisse(Long clotureId, Long valideParId, String commentaireTresor) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new RuntimeException("Clôture de caisse non trouvée"));

        if (clotureCaisse.getStatut() != StatutCloture.SOUMISE) {
            throw new RuntimeException("Seules les clôtures soumises peuvent être rejetées");
        }

        Agents validePar = agentRepository.findById(valideParId)
                .orElseThrow(() -> new RuntimeException("Agent validateur non trouvé"));

        clotureCaisse.setStatut(StatutCloture.REJETEE);
        clotureCaisse.setValidePar(validePar);
        clotureCaisse.setCommentaireTresor(commentaireTresor);
        clotureCaisse.setDateValidationTresor(LocalDateTime.now());

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO confirmerDepotBanque(Long clotureId, BigDecimal montantDepose, String referenceDepot) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new RuntimeException("Clôture de caisse non trouvée"));

        if (clotureCaisse.getStatut() != StatutCloture.VALIDEE) {
            throw new RuntimeException("Seules les clôtures validées peuvent recevoir une confirmation de dépôt");
        }

        clotureCaisse.setMontantDepose(montantDepose);
        clotureCaisse.setReferenceDepotBanque(referenceDepot);
        clotureCaisse.setDateDepotBanque(LocalDateTime.now());
        clotureCaisse.setStatut(StatutCloture.DEPOSEE);

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    @Transactional(readOnly = true)
    public Optional<ClotureCaisseDTO> getClotureCaisseById(Long id) {
        return clotureCaisseRepository.findById(id)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public Optional<ClotureCaisseDTO> getClotureCaisseByAgentAndDate(Long agentId, LocalDate date) {
        return clotureCaisseRepository.findByAgentIdAndDateCloture(agentId, date)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public List<ClotureCaisseDTO> getClotureCaisseByAgent(Long agentId) {
        return clotureCaisseRepository.findByAgentIdOrderByDateClotureDesc(agentId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ClotureCaisseDTO> getClotureCaisseByStatut(StatutCloture statut) {
        return clotureCaisseRepository.findByStatut(statut)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ClotureCaisseDTO> getClotureCaisseByDateRange(LocalDate debut, LocalDate fin) {
        return clotureCaisseRepository.findByDateClotureBetween(debut, fin)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private ClotureCaisseDTO convertToDTO(ClotureCaisse clotureCaisse) {
        ClotureCaisseDTO dto = new ClotureCaisseDTO();
        dto.setId(clotureCaisse.getId());
        dto.setAgentId(clotureCaisse.getAgent().getId());
        dto.setDateCloture(clotureCaisse.getDateCloture());
        dto.setMontantTotalEspece(clotureCaisse.getMontantTotalEspece());
        dto.setMontantTotalMobileMoney(clotureCaisse.getMontantTotalMobileMoney());
        dto.setMontantTotal(clotureCaisse.getMontantTotal());
        dto.setMontantDeclare(clotureCaisse.getMontantDeclare());
        dto.setMontantDepose(clotureCaisse.getMontantDepose());
        dto.setReferenceDepotBanque(clotureCaisse.getReferenceDepotBanque());
        dto.setDateDepotBanque(clotureCaisse.getDateDepotBanque());
        dto.setStatut(clotureCaisse.getStatut());
        dto.setCommentaireAgent(clotureCaisse.getCommentaireAgent());
        dto.setCommentaireTresor(clotureCaisse.getCommentaireTresor());
        dto.setDateValidationTresor(clotureCaisse.getDateValidationTresor());
        dto.setNombreTransactions(clotureCaisse.getNombreTransactions());

        // Informations additionnelles
        dto.setAgentNom(clotureCaisse.getAgent().getNom());
        dto.setAgentPrenom(clotureCaisse.getAgent().getPrenom());

        if (clotureCaisse.getValidePar() != null) {
            dto.setValideParId(clotureCaisse.getValidePar().getId());
            dto.setValideParNom(clotureCaisse.getValidePar().getNom());
            dto.setValideParPrenom(clotureCaisse.getValidePar().getPrenom());
        }

        return dto;
    }
}
