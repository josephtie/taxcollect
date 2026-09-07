package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import com.nectuxingenieries.collect.tax.models.enums.StatutPayment;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
import com.nectuxingenieries.collect.tax.models.enums.TypeCalcul;
import com.nectuxingenieries.collect.tax.models.mappers.TaxeCollectMapper;
import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.repositories.TaxeCollectRepository;
import com.nectuxingenieries.collect.tax.repositories.TaxeRepository;
import com.nectuxingenieries.collect.tax.services.AssessmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
@Log4j2
public class AssessmentServiceImpl implements AssessmentService {

    @Autowired
    private TaxeRepository taxeRepository;

    @Autowired
    private TaxeCollectRepository taxeCollectRepository;

    @Autowired
    private ContribuableRepository contribuableRepository;

    @Autowired
    private TaxeCollectMapper taxeCollectMapper;

    @Override
    public int generateForPeriod(Long taxeId, LocalDate targetDate) {
        Taxe taxe = taxeRepository.findById(taxeId)
                .orElseThrow(() -> new RuntimeException("Taxe non trouvée: " + taxeId));

        if (taxe.getDeletedAt() != null) {
            log.warn("Taxe {} supprimée, génération ignorée", taxeId);
            return 0;
        }

        LocalDate periodStart = calculatePeriodStart(taxe.getPeriodicite(), targetDate);
        LocalDate periodEnd = calculatePeriodEnd(taxe.getPeriodicite(), periodStart);
        LocalDate dueDate = calculateDueDate(taxe.getPeriodicite(), periodStart, periodEnd);

        List<Contribuable> contribuables = contribuableRepository.findActiveContribuables();
        int generated = 0;

        for (Contribuable contribuable : contribuables) {
            String taxType = taxe.getNom();

            Optional<TaxeCollect> existing = taxeCollectRepository
                    .findByContribuableAndTaxeAndPeriodStart(contribuable.getId(), taxType, periodStart);

            if (existing.isPresent()) {
                continue;
            }

            BigDecimal montant = calculateMontant(taxe, contribuable);

            TaxeCollect avis = new TaxeCollect();
            avis.setMontant(montant);
            avis.setRemainingAmount(montant);
            avis.setDateEmission(LocalDate.now());
            avis.setDateLimite(dueDate);
            avis.setDueDate(dueDate);
            avis.setPeriodStart(periodStart);
            avis.setPeriodEnd(periodEnd);
            avis.setPaye(false);
            avis.setContribuable(contribuable);
            avis.setZone(contribuable.getZone());
            avis.setTaxe(taxe);
            avis.setStatut(StatutPayment.IMPAYE);
            avis.setCurrency("XOF");
            avis.setTaxType(taxe.getNom());
            avis.setReference(generateReference(taxe, contribuable, periodStart));

            taxeCollectRepository.save(avis);
            generated++;
        }

        log.info("Génération d'avis pour la taxe {} (période {} → {}): {} avis créés",
                taxe.getNom(), periodStart, periodEnd, generated);
        return generated;
    }

    @Override
    public int generateForAllActiveTaxes(LocalDate targetDate) {
        List<Taxe> activeTaxes = taxeRepository.findAll().stream()
                .filter(t -> t.getDeletedAt() == null)
                .toList();

        int total = 0;
        for (Taxe taxe : activeTaxes) {
            total += generateForPeriod(taxe.getId(), targetDate);
        }
        log.info("Génération globale pour {}: {} avis créés au total", targetDate, total);
        return total;
    }

    @Override
    public int markOverdueAssessments() {
        List<TaxeCollect> overdue = taxeCollectRepository
                .findOverdueAssessments(StatutPayment.IMPAYE, LocalDate.now());

        for (TaxeCollect avis : overdue) {
            avis.setStatut(StatutPayment.EN_RETARD);
            taxeCollectRepository.save(avis);
        }

        log.info("{} avis marqués en retard", overdue.size());
        return overdue.size();
    }

    @Override
    @Transactional(readOnly = true)
    public List<TaxeCollectDto> findAssessmentsByPeriod(LocalDate periodStart, LocalDate periodEnd) {
        return taxeCollectRepository.findAll().stream()
                .filter(tc -> tc.getPeriodStart() != null
                        && !tc.getPeriodStart().isBefore(periodStart)
                        && !tc.getPeriodStart().isAfter(periodEnd))
                .map(taxeCollectMapper::toDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public byte[] exportAssessments(String format, LocalDate periodStart, LocalDate periodEnd) {
        List<TaxeCollect> assessments = taxeCollectRepository.findAll().stream()
                .filter(tc -> tc.getPeriodStart() != null
                        && !tc.getPeriodStart().isBefore(periodStart)
                        && !tc.getPeriodStart().isAfter(periodEnd))
                .toList();

        if ("xlsx".equalsIgnoreCase(format)) {
            return exportAssessmentsToXlsx(assessments);
        } else {
            return exportAssessmentsToCsv(assessments);
        }
    }

    private byte[] exportAssessmentsToCsv(List<TaxeCollect> assessments) {
        StringBuilder sb = new StringBuilder();
        sb.append("Reference,Contribuable,TaxeType,Montant,Statut,PeriodStart,PeriodEnd,DueDate\n");
        for (TaxeCollect tc : assessments) {
            sb.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s\n",
                    escapeCsv(tc.getReference()),
                    escapeCsv(tc.getContribuable() != null ? tc.getContribuable().getNom() + " " + tc.getContribuable().getPrenom() : ""),
                    escapeCsv(tc.getTaxType()),
                    tc.getMontant() != null ? tc.getMontant().toPlainString() : "",
                    tc.getStatut() != null ? tc.getStatut().name() : "",
                    tc.getPeriodStart() != null ? tc.getPeriodStart().toString() : "",
                    tc.getPeriodEnd() != null ? tc.getPeriodEnd().toString() : "",
                    tc.getDueDate() != null ? tc.getDueDate().toString() : ""
            ));
        }
        return sb.toString().getBytes();
    }

    private byte[] exportAssessmentsToXlsx(List<TaxeCollect> assessments) {
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Avis d'imposition");

            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            String[] headers = {"Reference", "Contribuable", "Taxe", "Montant", "Statut", "Periode Debut", "Periode Fin", "Echeance"};
            for (int i = 0; i < headers.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4000);
            }

            int rowIdx = 1;
            for (TaxeCollect tc : assessments) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(tc.getReference() != null ? tc.getReference() : "");
                row.createCell(1).setCellValue(tc.getContribuable() != null ? tc.getContribuable().getNom() + " " + tc.getContribuable().getPrenom() : "");
                row.createCell(2).setCellValue(tc.getTaxType() != null ? tc.getTaxType() : "");
                row.createCell(3).setCellValue(tc.getMontant() != null ? tc.getMontant().doubleValue() : 0);
                row.createCell(4).setCellValue(tc.getStatut() != null ? tc.getStatut().name() : "");
                row.createCell(5).setCellValue(tc.getPeriodStart() != null ? tc.getPeriodStart().toString() : "");
                row.createCell(6).setCellValue(tc.getPeriodEnd() != null ? tc.getPeriodEnd().toString() : "");
                row.createCell(7).setCellValue(tc.getDueDate() != null ? tc.getDueDate().toString() : "");
            }

            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            workbook.write(baos);
            return baos.toByteArray();
        } catch (java.io.IOException e) {
            throw new RuntimeException("Erreur lors de la génération du fichier Excel", e);
        }
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    private LocalDate calculatePeriodStart(TaxePeriodicite periodicite, LocalDate targetDate) {
        return switch (periodicite) {
            case JOURNALIERE -> targetDate;
            case MENSUELLE -> targetDate.withDayOfMonth(1);
            case TRIMESTRIELLE -> {
                int month = targetDate.getMonthValue();
                int quarterStartMonth = ((month - 1) / 3) * 3 + 1;
                yield targetDate.withMonth(quarterStartMonth).withDayOfMonth(1);
            }
            case ANNUELLE -> targetDate.withMonth(1).withDayOfMonth(1);
        };
    }

    private LocalDate calculatePeriodEnd(TaxePeriodicite periodicite, LocalDate periodStart) {
        return switch (periodicite) {
            case JOURNALIERE -> periodStart;
            case MENSUELLE -> periodStart.plusMonths(1).minusDays(1);
            case TRIMESTRIELLE -> periodStart.plusMonths(3).minusDays(1);
            case ANNUELLE -> periodStart.withMonth(12).withDayOfMonth(31);
        };
    }

    private LocalDate calculateDueDate(TaxePeriodicite periodicite, LocalDate periodStart, LocalDate periodEnd) {
        return switch (periodicite) {
            case JOURNALIERE -> periodStart.plusDays(15);
            case MENSUELLE -> periodEnd.plusDays(15);
            case TRIMESTRIELLE -> periodEnd.plusDays(30);
            case ANNUELLE -> LocalDate.of(periodStart.getYear() + 1, 3, 31);
        };
    }

    private String generateReference(Taxe taxe, Contribuable contribuable, LocalDate periodStart) {
        String prefix = "AVIS";
        String taxeCode = taxe.getNom() != null ? taxe.getNom().substring(0, Math.min(3, taxe.getNom().length())).toUpperCase() : "TX";
        String period = periodStart.toString().replace("-", "");
        String contribuableId = String.format("%06d", contribuable.getId());
        return prefix + "-" + taxeCode + "-" + period + "-" + contribuableId;
    }

    private BigDecimal calculateMontant(Taxe taxe, Contribuable contribuable) {
        if (taxe.getTypeCalcul() == TypeCalcul.MONTANT && taxe.getMontantFixe() != null) {
            return taxe.getMontantFixe();
        }
        if (taxe.getTypeCalcul() == TypeCalcul.TAUX && taxe.getTaux() != null) {
            BigDecimal baseAnnuelle = resolveBaseImposable(contribuable);
            BigDecimal baseProrata = prorataBaseAnnuelle(baseAnnuelle, taxe.getPeriodicite());
            return baseProrata.multiply(taxe.getTaux()).setScale(0, java.math.RoundingMode.HALF_UP);
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal resolveBaseImposable(Contribuable contribuable) {
        if (contribuable.getBaseImposable() != null && contribuable.getBaseImposable().compareTo(BigDecimal.ZERO) > 0) {
            return contribuable.getBaseImposable();
        }
        return estimateBaseAnnuelleByActivite(contribuable.getActivite());
    }

    private BigDecimal prorataBaseAnnuelle(BigDecimal baseAnnuelle, TaxePeriodicite periodicite) {
        return switch (periodicite) {
            case ANNUELLE -> baseAnnuelle;
            case TRIMESTRIELLE -> baseAnnuelle.divide(BigDecimal.valueOf(4), 0, java.math.RoundingMode.HALF_UP);
            case MENSUELLE -> baseAnnuelle.divide(BigDecimal.valueOf(12), 0, java.math.RoundingMode.HALF_UP);
            case JOURNALIERE -> baseAnnuelle.divide(BigDecimal.valueOf(365), 0, java.math.RoundingMode.HALF_UP);
        };
    }

    private BigDecimal estimateBaseAnnuelleByActivite(String activite) {
        if (activite == null || activite.isBlank()) {
            return BigDecimal.valueOf(600000);
        }
        String a = activite.toLowerCase().trim();
        if (a.contains("commerce") || a.contains("boutique") || a.contains("magasin")) {
            return BigDecimal.valueOf(3000000);
        }
        if (a.contains("restaurant") || a.contains("maquis") || a.contains("bar")) {
            return BigDecimal.valueOf(1800000);
        }
        if (a.contains("transport") || a.contains("taxi") || a.contains("moto")) {
            return BigDecimal.valueOf(1200000);
        }
        if (a.contains("artisan") || a.contains("atelier") || a.contains("réparation")) {
            return BigDecimal.valueOf(1440000);
        }
        if (a.contains("coiffure") || a.contains("salon") || a.contains("beauté")) {
            return BigDecimal.valueOf(960000);
        }
        if (a.contains("pharmacie") || a.contains("clinique") || a.contains("médecin")) {
            return BigDecimal.valueOf(6000000);
        }
        if (a.contains("hôtel") || a.contains("hébergement")) {
            return BigDecimal.valueOf(4800000);
        }
        if (a.contains("marché") || a.contains("etalage") || a.contains("ambulant")) {
            return BigDecimal.valueOf(360000);
        }
        return BigDecimal.valueOf(600000);
    }
}
