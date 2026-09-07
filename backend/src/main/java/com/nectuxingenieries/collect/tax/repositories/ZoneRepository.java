package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Zone;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ZoneRepository extends BaseRepository<Zone, Long>, JpaSpecificationExecutor<Zone> {

    @Query("SELECT z FROM Zone z WHERE z.nom = ?1 AND z.deletedAt IS NULL")
    Optional<Zone> findByNom(String nom);

    @Query("SELECT z FROM Zone z WHERE z.commune.id = ?1 AND z.deletedAt IS NULL")
    List<Zone> findByCommuneId(Long communeId);

    @Query("SELECT z FROM Zone z WHERE z.statut IS TRUE AND z.deletedAt IS NULL")
    List<Zone> findActiveZones();

    @Query("SELECT COUNT(z) FROM Zone z WHERE z.commune.id = :communeId AND z.deletedAt IS NULL")
    long countByCommuneId(@Param("communeId") Long communeId);

    @Query("SELECT z FROM Zone z WHERE z.createdAt BETWEEN :startDate AND :endDate AND z.deletedAt IS NULL")
    List<Zone> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT CASE WHEN COUNT(z) > 0 THEN true ELSE false END FROM Zone z WHERE z.nom = ?1 AND z.deletedAt IS NULL")
    boolean existsByNom(String nom);

    @Query("SELECT z FROM Zone z WHERE (LOWER(z.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(z.commune.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND z.deletedAt IS NULL")
    List<Zone> searchByNomOrCommune(@Param("searchTerm") String searchTerm);

    @Query("SELECT DISTINCT z FROM Zone z JOIN z.agents a WHERE z.statut IS TRUE AND z.deletedAt IS NULL")
    List<Zone> findZonesWithAgents();

    @Query("SELECT z.id, z.nom, COUNT(a) FROM Zone z LEFT JOIN z.agents a WHERE z.deletedAt IS NULL GROUP BY z.id, z.nom")
    List<Object[]> countAgentsByZone();

    @Query("SELECT z FROM Zone z WHERE SIZE(z.agents) = 0 AND z.deletedAt IS NULL")
    List<Zone> findZonesWithoutAgents();

    @Query(value = "SELECT * FROM zone z WHERE z.deleted_at IS NULL AND z.geometry IS NOT NULL AND ST_Contains(z.geometry, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)) LIMIT 1", nativeQuery = true)
    Zone findByGeometryContaining(@Param("lat") double latitude, @Param("lng") double longitude);

    @Query("SELECT z FROM Zone z WHERE z.superviseurId = :superviseurId AND z.deletedAt IS NULL")
    List<Zone> findBySuperviseurId(@Param("superviseurId") String superviseurId);

    @Query("SELECT z FROM Zone z WHERE (z.superviseurId IS NULL OR z.superviseurId <> :superviseurId) AND z.deletedAt IS NULL")
    List<Zone> findUnassignedZones(@Param("superviseurId") String superviseurId);
}
