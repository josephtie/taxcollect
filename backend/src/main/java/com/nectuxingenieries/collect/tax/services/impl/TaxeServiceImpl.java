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
    public byte[] exportTaxes(String format, String categorie) {
        // TODO: Implémenter l'exportation
        return new byte[0];
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
