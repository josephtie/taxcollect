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

    @Query("SELECT q FROM Quartier q WHERE q.zone.id = ?1 AND q.deletedAt IS NULL")
    List<Quartier> findByZoneId(Long zoneId);
    
    @Query("SELECT q FROM Quartier q WHERE q.zone.id = ?1 AND q.deletedAt IS NULL")
    Page<Quartier> findByZoneId(Long zoneId, Pageable pageable);
    
    @Query("SELECT q FROM Quartier q WHERE LOWER(q.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) AND q.deletedAt IS NULL ORDER BY q.nom ASC")
    List<Quartier> searchByNom(@Param("searchTerm") String searchTerm);

    @Query(value = "SELECT * FROM quartier q WHERE q.deleted_at IS NULL AND q.geometry IS NOT NULL AND ST_Contains(q.geometry, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)) LIMIT 1", nativeQuery = true)
    Quartier findByGeometryContaining(@Param("lat") double latitude, @Param("lng") double longitude);
}
