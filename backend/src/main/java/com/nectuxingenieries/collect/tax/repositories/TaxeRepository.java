package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Taxe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaxeRepository extends BaseRepository<Taxe, Long>, JpaSpecificationExecutor<Taxe> {

    List<Taxe> findByPeriodicite(String periodicite);
    
    @Query("SELECT t FROM Taxe t WHERE t.categorie = ?1 AND t.deletedAt IS NULL")
    Page<Taxe> findByCategorie(String categorie, Pageable pageable);
    
    @Query("SELECT DISTINCT t.categorie FROM Taxe t WHERE t.deletedAt IS NULL")
    List<String> findActiveCategories();
    
    @Query("SELECT DISTINCT t.periodicite FROM Taxe t WHERE t.deletedAt IS NULL")
    List<String> findActivePeriodicites();
}

