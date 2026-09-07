package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.repositories.TaxeRepository;
import com.nectuxingenieries.collect.tax.models.Taxe;
import com.nectuxingenieries.collect.tax.dto.TaxeDto;
import com.nectuxingenieries.collect.tax.models.mappers.TaxeMapper;
import com.nectuxingenieries.collect.tax.security.LogicalDeletionPermissions;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import com.nectuxingenieries.collect.tax.services.TaxeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class TaxeServiceImpl extends BaseServiceImpl<Taxe, Long, TaxeDto, TaxeRepository> implements TaxeService {

    private final TaxeRepository taxeRepository;
    private final TaxeMapper taxeMapper;

    @Autowired
    public TaxeServiceImpl(TaxeRepository taxeRepository, TaxeMapper taxeMapper, LogicalDeletionPermissions permissions) {
        super(taxeRepository, taxeMapper::toEntity, taxeMapper::toDto, permissions);
        this.taxeRepository = taxeRepository;
        this.taxeMapper = taxeMapper;
    }

    // Méthodes spécifiques aux taxes
    @Override
    @Transactional(readOnly = true)
    public Page<TaxeDto> findAll(Pageable pageable) {
        return taxeRepository.findAll(pageable).map(taxeMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TaxeDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Taxe> specification = GenericSpecifications.fromMap(filters);
        return taxeRepository.findAll(specification, pageable).map(taxeMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TaxeDto> searchTaxes(String searchTerm, Map<String, String> filters, Pageable pageable) {
        Specification<Taxe> specification = Specification.where(null);
        
        // Recherche par nom ou description
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            specification = specification.and((root, query, criteriaBuilder) ->
                criteriaBuilder.or(
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("nom")),
                        "%" + searchTerm.toLowerCase() + "%"
                    ),
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("description")),
                        "%" + searchTerm.toLowerCase() + "%"
                    )
                )
            );
        }
        
        return taxeRepository.findAll(specification, pageable).map(taxeMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getCategories() {
        return taxeRepository.findActiveCategories();
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getPeriodicites() {
        return taxeRepository.findActivePeriodicites();
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getTaxeStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // Statistiques générales
        stats.put("totalTaxes", taxeRepository.countActive());
        stats.put("categories", getCategories());
        stats.put("periodicites", getPeriodicites());
        
        // TODO: Ajouter des statistiques plus détaillées
        
        return stats;
    }

    @Override
    @Transactional(readOnly = true)
    public byte[] exportTaxes(String format, String categorie) {
        List<Taxe> taxes = taxeRepository.findAll().stream()
                .filter(t -> t.getDeletedAt() == null)
                .filter(t -> categorie == null || categorie.isBlank()
                        || (t.getCategorie() != null && t.getCategorie().name().equalsIgnoreCase(categorie)))
                .toList();

        if ("xlsx".equalsIgnoreCase(format)) {
            return exportTaxesToXlsx(taxes);
        } else {
            return exportTaxesToCsv(taxes);
        }
    }

    private byte[] exportTaxesToCsv(List<Taxe> taxes) {
        StringBuilder sb = new StringBuilder();
        sb.append("Nom,Description,Categorie,Periodicite,TypeCalcul,Taux,MontantFixe\n");
        for (Taxe t : taxes) {
            sb.append(String.format("%s,%s,%s,%s,%s,%s,%s\n",
                    escapeCsv(t.getNom()),
                    escapeCsv(t.getDescription()),
                    t.getCategorie() != null ? t.getCategorie().name() : "",
                    t.getPeriodicite() != null ? t.getPeriodicite().name() : "",
                    t.getTypeCalcul() != null ? t.getTypeCalcul().name() : "",
                    t.getTaux() != null ? t.getTaux().toPlainString() : "",
                    t.getMontantFixe() != null ? t.getMontantFixe().toPlainString() : ""
            ));
        }
        return sb.toString().getBytes();
    }

    private byte[] exportTaxesToXlsx(List<Taxe> taxes) {
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Taxes");

            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            String[] headers = {"Nom", "Description", "Categorie", "Periodicite", "TypeCalcul", "Taux", "MontantFixe"};
            for (int i = 0; i < headers.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4000);
            }

            int rowIdx = 1;
            for (Taxe t : taxes) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(t.getNom() != null ? t.getNom() : "");
                row.createCell(1).setCellValue(t.getDescription() != null ? t.getDescription() : "");
                row.createCell(2).setCellValue(t.getCategorie() != null ? t.getCategorie().name() : "");
                row.createCell(3).setCellValue(t.getPeriodicite() != null ? t.getPeriodicite().name() : "");
                row.createCell(4).setCellValue(t.getTypeCalcul() != null ? t.getTypeCalcul().name() : "");
                row.createCell(5).setCellValue(t.getTaux() != null ? t.getTaux().doubleValue() : 0);
                row.createCell(6).setCellValue(t.getMontantFixe() != null ? t.getMontantFixe().doubleValue() : 0);
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

    @Override
    public TaxeDto duplicateTaxe(Long id) {
        Taxe original = taxeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Taxe non trouvée"));
        
        Taxe duplicate = new Taxe();
        duplicate.setNom(original.getNom() + " (copie)");
        duplicate.setDescription(original.getDescription());
        duplicate.setTaux(original.getTaux());
        duplicate.setMontantFixe(original.getMontantFixe());
        duplicate.setTypeCalcul(original.getTypeCalcul());
        duplicate.setCategorie(original.getCategorie());
        duplicate.setPeriodicite(original.getPeriodicite());
        
        return taxeMapper.toDto(taxeRepository.save(duplicate));
    }

    @Override
    protected void updateEntityFromDto(Taxe entity, TaxeDto dto) {
        // Utiliser le mapper pour mettre à jour l'entité
        taxeMapper.updateFromDto(dto, entity);
    }
}
