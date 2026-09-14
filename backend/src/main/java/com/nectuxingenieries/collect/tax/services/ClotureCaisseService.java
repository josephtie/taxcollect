package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.exceptions.ConflictException;
import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.exceptions.InvalidOperationException;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
            throw new ConflictException("Une clôture de caisse existe déjà pour cet agent à cette date");
        }

        Agents agent = agentRepository.findById(agentId)
                .orElseThrow(() -> new NotFoundException("Agent", agentId));

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
                    montantTotalEspece = montantTotalEspece.add(transaction.getMontant());
                } else if (transaction.getModePaiement() == ModePaiement.MOBILE_MONEY) {
                    montantTotalMobileMoney = montantTotalMobileMoney.add(transaction.getMontant());
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
                .orElseThrow(() -> new NotFoundException("Clôture de caisse", clotureId));

        if (clotureCaisse.getStatut() != StatutCloture.EN_COURS) {
            throw new InvalidOperationException("Cette clôture ne peut plus être modifiée");
        }

        clotureCaisse.setMontantDeclare(montantDeclare);
        clotureCaisse.setCommentaireAgent(commentaireAgent);
        clotureCaisse.setStatut(StatutCloture.SOUMISE);

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO validerClotureCaisse(Long clotureId, Long valideParId, String commentaireTresor) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new NotFoundException("Clôture de caisse", clotureId));

        if (clotureCaisse.getStatut() != StatutCloture.SOUMISE) {
            throw new InvalidOperationException("Seules les clôtures soumises peuvent être validées");
        }

        Agents validePar = agentRepository.findById(valideParId)
                .orElseThrow(() -> new NotFoundException("Agent validateur", valideParId));

        clotureCaisse.setStatut(StatutCloture.VALIDEE);
        clotureCaisse.setValidePar(validePar);
        clotureCaisse.setCommentaireTresor(commentaireTresor);
        clotureCaisse.setDateValidationTresor(LocalDateTime.now());

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO rejeterClotureCaisse(Long clotureId, Long valideParId, String commentaireTresor) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new NotFoundException("Clôture de caisse", clotureId));

        if (clotureCaisse.getStatut() != StatutCloture.SOUMISE) {
            throw new InvalidOperationException("Seules les clôtures soumises peuvent être rejetées");
        }

        Agents validePar = agentRepository.findById(valideParId)
                .orElseThrow(() -> new NotFoundException("Agent validateur", valideParId));

        clotureCaisse.setStatut(StatutCloture.REJETEE);
        clotureCaisse.setValidePar(validePar);
        clotureCaisse.setCommentaireTresor(commentaireTresor);
        clotureCaisse.setDateValidationTresor(LocalDateTime.now());

        ClotureCaisse savedCloture = clotureCaisseRepository.save(clotureCaisse);
        return convertToDTO(savedCloture);
    }

    public ClotureCaisseDTO confirmerDepotBanque(Long clotureId, BigDecimal montantDepose, String referenceDepot) {
        ClotureCaisse clotureCaisse = clotureCaisseRepository.findById(clotureId)
                .orElseThrow(() -> new NotFoundException("Clôture de caisse", clotureId));

        if (clotureCaisse.getStatut() != StatutCloture.VALIDEE) {
            throw new InvalidOperationException("Seules les clôtures validées peuvent recevoir une confirmation de dépôt");
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

    /**
     * Statistiques de clôture sur une période : volumes par statut, montants cumulés
     * et écart global entre le déclaré et le calculé.
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getClotureStats(LocalDate debut, LocalDate fin) {
        List<ClotureCaisse> clotures = (debut != null && fin != null)
                ? clotureCaisseRepository.findByDateClotureBetween(debut, fin)
                : clotureCaisseRepository.findAll();

        Map<String, Long> parStatut = new LinkedHashMap<>();
        for (StatutCloture statut : StatutCloture.values()) {
            parStatut.put(statut.name(), clotures.stream()
                    .filter(c -> c.getStatut() == statut)
                    .count());
        }

        BigDecimal montantTotal = sum(clotures, ClotureCaisse::getMontantTotal);
        BigDecimal montantDeclare = sum(clotures, ClotureCaisse::getMontantDeclare);
        BigDecimal montantDepose = sum(clotures, ClotureCaisse::getMontantDepose);

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("nombreClotures", clotures.size());
        stats.put("parStatut", parStatut);
        stats.put("montantTotalEspece", sum(clotures, ClotureCaisse::getMontantTotalEspece));
        stats.put("montantTotalMobileMoney", sum(clotures, ClotureCaisse::getMontantTotalMobileMoney));
        stats.put("montantTotal", montantTotal);
        stats.put("montantDeclare", montantDeclare);
        stats.put("montantDepose", montantDepose);
        stats.put("ecartDeclare", montantDeclare.subtract(montantTotal));
        stats.put("ecartDepose", montantDepose.subtract(montantDeclare));
        stats.put("nombreTransactions", clotures.stream()
                .mapToInt(c -> c.getNombreTransactions() != null ? c.getNombreTransactions() : 0)
                .sum());
        return stats;
    }

    /**
     * Exporte les bordereaux de clôture d'une période au format CSV ou XLSX.
     */
    @Transactional(readOnly = true)
    public byte[] exportClotures(String format, LocalDate debut, LocalDate fin) {
        List<ClotureCaisse> clotures = (debut != null && fin != null)
                ? clotureCaisseRepository.findByDateClotureBetween(debut, fin)
                : clotureCaisseRepository.findAll();

        return "xlsx".equalsIgnoreCase(format)
                ? exportCloturesToXlsx(clotures)
                : exportCloturesToCsv(clotures);
    }

    private static final String[] EXPORT_HEADERS = {
            "Id", "Date", "Agent", "Especes", "MobileMoney", "Total",
            "Declare", "Depose", "Statut", "ReferenceDepot", "NombreTransactions"
    };

    private byte[] exportCloturesToCsv(List<ClotureCaisse> clotures) {
        StringBuilder sb = new StringBuilder();
        sb.append(String.join(",", EXPORT_HEADERS)).append("\n");
        for (ClotureCaisse c : clotures) {
            sb.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
                    c.getId(),
                    c.getDateCloture() != null ? c.getDateCloture() : "",
                    escapeCsv(agentLabel(c)),
                    plain(c.getMontantTotalEspece()),
                    plain(c.getMontantTotalMobileMoney()),
                    plain(c.getMontantTotal()),
                    plain(c.getMontantDeclare()),
                    plain(c.getMontantDepose()),
                    c.getStatut() != null ? c.getStatut().name() : "",
                    escapeCsv(c.getReferenceDepotBanque()),
                    c.getNombreTransactions() != null ? c.getNombreTransactions() : 0));
        }
        return sb.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);
    }

    private byte[] exportCloturesToXlsx(List<ClotureCaisse> clotures) {
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Clotures");

            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            for (int i = 0; i < EXPORT_HEADERS.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(EXPORT_HEADERS[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4000);
            }

            int rowIdx = 1;
            for (ClotureCaisse c : clotures) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(c.getId() != null ? c.getId() : 0);
                row.createCell(1).setCellValue(c.getDateCloture() != null ? c.getDateCloture().toString() : "");
                row.createCell(2).setCellValue(agentLabel(c));
                row.createCell(3).setCellValue(doubleOf(c.getMontantTotalEspece()));
                row.createCell(4).setCellValue(doubleOf(c.getMontantTotalMobileMoney()));
                row.createCell(5).setCellValue(doubleOf(c.getMontantTotal()));
                row.createCell(6).setCellValue(doubleOf(c.getMontantDeclare()));
                row.createCell(7).setCellValue(doubleOf(c.getMontantDepose()));
                row.createCell(8).setCellValue(c.getStatut() != null ? c.getStatut().name() : "");
                row.createCell(9).setCellValue(c.getReferenceDepotBanque() != null ? c.getReferenceDepotBanque() : "");
                row.createCell(10).setCellValue(c.getNombreTransactions() != null ? c.getNombreTransactions() : 0);
            }

            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            workbook.write(out);
            return out.toByteArray();
        } catch (java.io.IOException e) {
            throw new RuntimeException("Erreur lors de l'export XLSX des clôtures", e);
        }
    }

    private BigDecimal sum(List<ClotureCaisse> clotures, java.util.function.Function<ClotureCaisse, BigDecimal> getter) {
        return clotures.stream()
                .map(getter)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private String agentLabel(ClotureCaisse c) {
        if (c.getAgent() == null) {
            return "";
        }
        return String.format("%s %s", nullToEmpty(c.getAgent().getNom()), nullToEmpty(c.getAgent().getPrenom())).trim();
    }

    private String plain(BigDecimal value) {
        return value != null ? value.toPlainString() : "";
    }

    private double doubleOf(BigDecimal value) {
        return value != null ? value.doubleValue() : 0d;
    }

    private String nullToEmpty(String value) {
        return value != null ? value : "";
    }

    private String escapeCsv(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
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
