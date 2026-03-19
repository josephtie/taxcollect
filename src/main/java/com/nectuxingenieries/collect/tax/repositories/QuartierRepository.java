package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Quartier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuartierRepository extends BaseRepository<Quartier, Long>, JpaSpecificationExecutor<Quartier> {

    @Query("SELECT q FROM Quartier q WHERE q.commune.id = ?1 AND q.deletedAt IS NULL")
    List<Quartier> findByCommuneId(Long communeId);
    
    @Query("SELECT q FROM Quartier q WHERE q.commune.id = ?1 AND q.deletedAt IS NULL")
    Page<Quartier> findByCommuneId(Long communeId, Pageable pageable);
    
    @Query("SELECT q FROM Quartier q WHERE LOWER(q.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) AND q.deletedAt IS NULL ORDER BY q.nom ASC")
    List<Quartier> searchByNom(@Param("searchTerm") String searchTerm);
}
