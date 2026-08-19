package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Commune;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommuneRepository extends BaseRepository<Commune, Long>, JpaSpecificationExecutor<Commune> {

    @Query("SELECT c FROM Commune c WHERE c.deletedAt IS NULL ORDER BY c.nom ASC")
    List<Commune> findAllByOrderByNomAsc();
    
    @Query("SELECT c FROM Commune c WHERE c.deletedAt IS NULL ORDER BY c.nom ASC")
    Page<Commune> findAllByOrderByNomAsc(Pageable pageable);
    
    @Query("SELECT c FROM Commune c WHERE LOWER(c.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) AND c.deletedAt IS NULL ORDER BY c.nom ASC")
    List<Commune> searchByNom(@Param("searchTerm") String searchTerm);
}
