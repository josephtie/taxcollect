package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Contribuable;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ContribuableRepository extends BaseRepository<Contribuable, Long>, JpaSpecificationExecutor<Contribuable> {
    
    /**
     * Trouver un contribuable par son email (non supprimé)
     */
    @Query("SELECT c FROM Contribuable c WHERE c.email = ?1 AND c.deletedAt IS NULL")
    Optional<Contribuable> findByEmail(String email);
    
    /**
     * Trouver un contribuable par son téléphone (non supprimé)
     */
    @Query("SELECT c FROM Contribuable c WHERE c.telephone = ?1 AND c.deletedAt IS NULL")
    Optional<Contribuable> findByTelephone(String telephone);
    
    /**
     * Trouver des contribuables par zone de collecte (non supprimés)
     */
    @Query("SELECT c FROM Contribuable c WHERE c.zoneCollecte.id = ?1 AND c.deletedAt IS NULL")
    List<Contribuable> findByZoneCollecteId(Long zoneCollecteId);
    
    /**
     * Trouver des contribuables actifs (non supprimés)
     */
    @Query("SELECT c FROM Contribuable c WHERE c.zoneCollecte.statut IS TRUE")
    List<Contribuable> findActiveContribuables();
    
    /**
     * Compter les contribuables par zone
     */
    @Query("SELECT COUNT(c) FROM Contribuable c WHERE c.zoneCollecte.id = :zoneId ")
    long countByZoneCollecteId(@Param("zoneId") Long zoneId);
    
    /**
     * Trouver des contribuables créés entre deux dates
     */
//    @Query("SELECT c FROM Contribuable c WHERE c.createdAt BETWEEN :startDate AND :endDate ")
//    List<Contribuable> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
//
    /**
     * Vérifier si un email existe déjà
     */
    boolean existsByEmail(String email);
    
    /**
     * Vérifier si un téléphone existe déjà
     */
    boolean existsByTelephone(String telephone);
    
    /**
     * Rechercher des contribuables par nom, prénom ou téléphone
     */
    @Query("SELECT c FROM Contribuable c WHERE (LOWER(c.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(c.prenom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR c.telephone LIKE CONCAT('%', :searchTerm, '%')) ")
    List<Contribuable> searchByNomPrenomOrTelephone(@Param("searchTerm") String searchTerm);
    
    /**
     * Trouver des contribuables avec coordonnées GPS définies
     */
    @Query("SELECT c FROM Contribuable c WHERE c.latitude IS NOT NULL AND c.longitude IS NOT NULL ")
    List<Contribuable> findContribuablesWithCoordinates();
    
    /**
     * Trouver des contribuables dans un rayon autour d'un point GPS
     */
    @Query(value = "SELECT * FROM contribuables c WHERE  " +
           "ST_DWithin(ST_Point(c.longitude, c.latitude)::geography, " +
           "ST_Point(:longitude, :latitude)::geography, :radius)", 
           nativeQuery = true)
    List<Contribuable> findContribuablesWithinRadius(
        @Param("latitude") double latitude, 
        @Param("longitude") double longitude, 
        @Param("radius") double radius
    );
}
