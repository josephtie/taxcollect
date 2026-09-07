package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.repositories.ContribuableRepository;
import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
import com.nectuxingenieries.collect.tax.models.mappers.ContribuableMapper;
import com.nectuxingenieries.collect.tax.services.ContribuableService;
import com.nectuxingenieries.collect.tax.services.GenericSpecifications;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class ContribuableServiceImpl implements ContribuableService {

    @Autowired
  private  ContribuableRepository contribuableRepository;
    @Autowired private  ContribuableMapper contribuableMapper;


    @Override
    public ContribuableDto create(ContribuableDto contribuableDto) {
        Contribuable entity = contribuableMapper.toEntity(contribuableDto);
        return contribuableMapper.toDto(contribuableRepository.save(entity));
    }
    @Override
    public ContribuableDto update(Long id, ContribuableDto contribuableDto) {
        Contribuable existing = contribuableRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
        contribuableMapper.updateFromDto(contribuableDto, existing);
        return contribuableMapper.toDto(contribuableRepository.save(existing));
    }
    @Override
    @Transactional(readOnly = true)
    public Optional<ContribuableDto> findById(Long id) {
        return contribuableRepository.findById(id)
                .map(contribuableMapper::toDto);
              //  .orElseThrow(() -> new RuntimeException("Contribuable non trouvé"));
    }
    @Override
    @Transactional(readOnly = true)
    public List<ContribuableDto> findAll() {
        return contribuableRepository.findAll()
                .stream()
                .map(contribuableMapper::toDto)
                .toList();
    }

    @Override
    public Page<ContribuableDto> findAll(Map<String,String> filters, Pageable pageable) {
        Specification<Contribuable> specification = GenericSpecifications.fromMap(filters);
        return contribuableRepository.findAll(specification, pageable).map(contribuableMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ContribuableDto> findAll(Pageable pageable) {
        return contribuableRepository.findAll(pageable).map(contribuableMapper::toDto);
    }
    @Override
    public void delete(Long id) {
        contribuableRepository.deleteById(id);
    }
    
    // Implémentation des méthodes manquantes
    @Override
    @Transactional(readOnly = true)
    public Page<ContribuableDto> searchContribuables(String searchTerm, Map<String, String> filters, Pageable pageable) {
        Specification<Contribuable> specification = Specification.where(null);
        
        // Recherche par nom, prénom, email ou téléphone
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            specification = specification.and((root, query, cb) -> 
                cb.or(
                    cb.like(cb.lower(root.get("nom")), "%" + searchTerm.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("prenom")), "%" + searchTerm.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("email")), "%" + searchTerm.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("telephone")), "%" + searchTerm.toLowerCase() + "%")
                )
            );
        }
        
        // Appliquer les filtres additionnels
        if (filters != null && !filters.isEmpty()) {
            Specification<Contribuable> filterSpec = GenericSpecifications.fromMap(filters);
            specification = specification.and(filterSpec);
        }
        
        return contribuableRepository.findAll(specification, pageable).map(contribuableMapper::toDto);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ContribuableDto> getContribuablesByZone(Long zoneId) {
        // Pour l'instant, retourner tous les contribuables
        // À implémenter avec la relation Zone-Contribuable
        return contribuableRepository.findAll()
                .stream()
                .map(contribuableMapper::toDto)
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getContribuableStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // Statistiques de base
        stats.put("totalContribuables", contribuableRepository.count());
        
        // Répartition par genre (si disponible)
        // stats.put("repartitionGenre", contribuableRepository.countByGenre());
        
        // Nombre de contribuables actifs
        // stats.put("contribuablesActifs", contribuableRepository.countByActifTrue());
        
        // Moyenne d'âge (si disponible)
        // stats.put("ageMoyen", contribuableRepository.getAverageAge());
        
        // Pour l'instant, retourner les stats de base
        stats.put("zonesCount", 0); // À implémenter avec ZoneRepository
        stats.put("averagePerZone", 0.0); // À calculer
        
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public byte[] exportContribuables(String format, Long zoneId) {
        List<Contribuable> contribuables = contribuableRepository.findAll();

        if (zoneId != null) {
            contribuables = contribuables.stream()
                    .filter(c -> c.getZone() != null && c.getZone().getId().equals(zoneId))
                    .collect(Collectors.toList());
        }

        if ("xlsx".equalsIgnoreCase(format)) {
            return exportContribuablesToXlsx(contribuables);
        } else {
            return exportContribuablesToCsv(contribuables);
        }
    }

    private byte[] exportContribuablesToCsv(List<Contribuable> contribuables) {
        StringBuilder sb = new StringBuilder();
        sb.append("Numero,Nom,Prenom,Telephone,Email,Type,Activite,Zone,Quartier,Statut,BaseImposable\n");
        for (Contribuable c : contribuables) {
            sb.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
                    escapeCsv(c.getNumeroContribuable()),
                    escapeCsv(c.getNom()),
                    escapeCsv(c.getPrenom()),
                    c.getTelephone() != null ? c.getTelephone() : "",
                    c.getEmail() != null ? c.getEmail() : "",
                    c.getTypeContribuable() != null ? c.getTypeContribuable() : "",
                    escapeCsv(c.getActivite()),
                    c.getZone() != null ? escapeCsv(c.getZone().getNom()) : "",
                    c.getQuartier() != null ? escapeCsv(c.getQuartier()) : "",
                    c.getStatut() != null ? c.getStatut() : "",
                    c.getBaseImposable() != null ? c.getBaseImposable().toPlainString() : ""
            ));
        }
        return sb.toString().getBytes();
    }

    private byte[] exportContribuablesToXlsx(List<Contribuable> contribuables) {
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Contribuables");

            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            String[] headers = {"Numero", "Nom", "Prenom", "Telephone", "Email", "Type", "Activite", "Zone", "Quartier", "Statut", "BaseImposable"};
            for (int i = 0; i < headers.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4000);
            }

            int rowIdx = 1;
            for (Contribuable c : contribuables) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(c.getNumeroContribuable() != null ? c.getNumeroContribuable() : "");
                row.createCell(1).setCellValue(c.getNom() != null ? c.getNom() : "");
                row.createCell(2).setCellValue(c.getPrenom() != null ? c.getPrenom() : "");
                row.createCell(3).setCellValue(c.getTelephone() != null ? c.getTelephone() : "");
                row.createCell(4).setCellValue(c.getEmail() != null ? c.getEmail() : "");
                row.createCell(5).setCellValue(c.getTypeContribuable() != null ? c.getTypeContribuable() : "");
                row.createCell(6).setCellValue(c.getActivite() != null ? c.getActivite() : "");
                row.createCell(7).setCellValue(c.getZone() != null ? c.getZone().getNom() : "");
                row.createCell(8).setCellValue(c.getQuartier() != null ? c.getQuartier() : "");
                row.createCell(9).setCellValue(c.getStatut() != null ? c.getStatut() : "");
                row.createCell(10).setCellValue(c.getBaseImposable() != null ? c.getBaseImposable().doubleValue() : 0);
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
}
