package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Secteur;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SecteurRepository extends BaseRepository<Secteur, Long>, JpaSpecificationExecutor<Secteur> {

    @Query("SELECT s FROM Secteur s WHERE s.quartier.id = ?1 AND s.deletedAt IS NULL")
    List<Secteur> findByQuartierId(Long quartierId);

    @Query("SELECT s FROM Secteur s WHERE LOWER(s.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) AND s.deletedAt IS NULL ORDER BY s.nom ASC")
    List<Secteur> searchByNom(@Param("searchTerm") String searchTerm);

    @Query(value = "SELECT * FROM secteur s WHERE s.deleted_at IS NULL AND s.geometry IS NOT NULL AND ST_Contains(s.geometry, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)) LIMIT 1", nativeQuery = true)
    Secteur findByGeometryContaining(@Param("lat") double latitude, @Param("lng") double longitude);
}
