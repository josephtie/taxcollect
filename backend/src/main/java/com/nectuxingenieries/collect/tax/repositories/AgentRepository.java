package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Agents;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AgentRepository extends BaseRepository<Agents, Long>, JpaSpecificationExecutor<Agents> {
    
    /**
     * Trouver un agent par son email (non supprimé)
     */
    @Query("SELECT a FROM Agents a WHERE a.email = ?1 AND a.deletedAt IS NULL")
    Optional<Agents> findByEmail(String email);
    
    /**
     * Trouver un agent par son téléphone (non supprimé)
     */
    @Query("SELECT a FROM Agents a WHERE a.telephone = ?1 AND a.deletedAt IS NULL")
    Optional<Agents> findByTelephone(String telephone);
    
    /**
     * Trouver des agents par statut (non supprimés)
     */
    @Query("SELECT a FROM Agents a WHERE a.statut = ?1 AND a.deletedAt IS NULL")
    List<Agents> findByStatut(String statut);
    
    /**
     * Trouver des agents par zone de collecte (non supprimés)
     */
    @Query("SELECT a FROM Agents a JOIN a.zoneCollectes z WHERE z.id = :zoneId AND a.deletedAt IS NULL")
    List<Agents> findByZoneCollecteId(@Param("zoneId") Long zoneId);
    
    /**
     * Trouver des agents actifs (non supprimés)
     */
    @Query("SELECT a FROM Agents a WHERE a.statut = 'ACTIF' AND a.deletedAt IS NULL")
    List<Agents> findActiveAgents();
    
    /**
     * Compter les agents par statut (non supprimés)
     */
    @Query("SELECT COUNT(a) FROM Agents a WHERE a.statut = :statut AND a.deletedAt IS NULL")
    long countByStatut(@Param("statut") String statut);
    
    /**
     * Trouver des agents créés entre deux dates (non supprimés)
     */
    @Query("SELECT a FROM Agents a WHERE a.createdAt BETWEEN :startDate AND :endDate AND a.deletedAt IS NULL")
    List<Agents> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    /**
     * Vérifier si un email existe déjà (non supprimé)
     */
    @Query("SELECT CASE WHEN COUNT(a) > 0 THEN true ELSE false END FROM Agents a WHERE a.email = ?1 AND a.deletedAt IS NULL")
    boolean existsByEmail(String email);
    
    /**
     * Vérifier si un téléphone existe déjà (non supprimé)
     */
    @Query("SELECT CASE WHEN COUNT(a) > 0 THEN true ELSE false END FROM Agents a WHERE a.telephone = ?1 AND a.deletedAt IS NULL")
    boolean existsByTelephone(String telephone);
    
    /**
     * Rechercher des agents par nom ou prénom (non supprimés)
     */
    @Query("SELECT a FROM Agents a WHERE (LOWER(a.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(a.prenom) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND a.deletedAt IS NULL")
    List<Agents> searchByNameOrPrenom(@Param("searchTerm") String searchTerm);
}
