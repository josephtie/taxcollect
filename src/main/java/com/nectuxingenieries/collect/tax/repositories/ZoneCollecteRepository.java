package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.ZoneCollecte;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ZoneCollecteRepository extends BaseRepository<ZoneCollecte, Long>, JpaSpecificationExecutor<ZoneCollecte> {
    
    /**
     * Trouver une zone par son nom (non supprimée)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE z.nom = ?1 AND z.deletedAt IS NULL")
    Optional<ZoneCollecte> findByNom(String nom);
    
    /**
     * Trouver des zones par quartier (non supprimées)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE z.quartier.id = ?1 AND z.deletedAt IS NULL")
    List<ZoneCollecte> findByQuartierId(Long quartierId);
    
    /**
     * Trouver des zones actives (non supprimées)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE z.statut IS TRUE AND z.deletedAt IS NULL")
    List<ZoneCollecte> findActiveZones();
    
    /**
     * Compter les zones par quartier (non supprimées)
     */
    @Query("SELECT COUNT(z) FROM ZoneCollecte z WHERE z.quartier.id = :quartierId AND z.deletedAt IS NULL")
    long countByQuartierId(@Param("quartierId") Long quartierId);
    
    /**
     * Trouver des zones créées entre deux dates (non supprimées)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE z.createdAt BETWEEN :startDate AND :endDate AND z.deletedAt IS NULL")
    List<ZoneCollecte> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    /**
     * Vérifier si une zone avec ce nom existe déjà (non supprimée)
     */
    @Query("SELECT CASE WHEN COUNT(z) > 0 THEN true ELSE false END FROM ZoneCollecte z WHERE z.nom = ?1 AND z.deletedAt IS NULL")
    boolean existsByNom(String nom);
    
    /**
     * Rechercher des zones par nom ou quartier (non supprimées)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE (LOWER(z.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(z.quartier.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND z.deletedAt IS NULL")
    List<ZoneCollecte> searchByNomOrQuartier(@Param("searchTerm") String searchTerm);
    
    /**
     * Trouver des zones avec des agents assignés (non supprimées)
     */
    @Query("SELECT DISTINCT z FROM ZoneCollecte z JOIN z.agents a WHERE z.statut IS TRUE AND z.deletedAt IS NULL")
    List<ZoneCollecte> findZonesWithAgents();
    
    /**
     * Compter le nombre d'agents par zone (non supprimées)
     */
    @Query("SELECT z.id, z.nom, COUNT(a) FROM ZoneCollecte z LEFT JOIN z.agents a WHERE z.deletedAt IS NULL GROUP BY z.id, z.nom")
    List<Object[]> countAgentsByZone();
    
    /**
     * Trouver les zones sans agents (non supprimées)
     */
    @Query("SELECT z FROM ZoneCollecte z WHERE SIZE(z.agents) = 0 AND z.deletedAt IS NULL")
    List<ZoneCollecte> findZonesWithoutAgents();
}
