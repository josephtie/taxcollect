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
        // Pour l'instant, retourner un contenu CSV basique
        // À implémenter avec Apache POI pour Excel ou CSV writer
        String content = "Nom,Prenom,Email,Telephone,Adresse,Zone\n";
        
        List<Contribuable> contribuables = contribuableRepository.findAll();
        
        if (zoneId != null) {
            // Filtrer par zone si spécifié
            contribuables = contribuables.stream()
                    .filter(c -> {
                        // Logique de filtrage par zone à implémenter
                        return true; // Pour l'instant, tous
                    })
                    .collect(Collectors.toList());
        }
        
        for (Contribuable contribuable : contribuables) {
            content += String.format("%s,%s,%s,%s,%s,%s\n",
                    contribuable.getNom(),
                    contribuable.getPrenom(),
                    contribuable.getEmail() != null ? contribuable.getEmail() : "",
                    contribuable.getTelephone() != null ? contribuable.getTelephone() : "",
                    contribuable.getAdresse() != null ? contribuable.getAdresse() : "",
                    "" // Zone à implémenter
            );
        }
        
        return content.getBytes();
    }
}
