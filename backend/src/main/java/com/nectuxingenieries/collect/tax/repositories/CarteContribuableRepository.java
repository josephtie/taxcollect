package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.CarteContribuable;
import com.nectuxingenieries.collect.tax.models.enums.CarteStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface CarteContribuableRepository extends JpaRepository<CarteContribuable, Long> {

    // Cartes d'un contribuable
    List<CarteContribuable> findByContribuableId(Long contribuableId);

    // Carte active d'un contribuable
    Optional<CarteContribuable> findByContribuableIdAndStatus(Long contribuableId, CarteStatus status);

    // Recherche par matricule
    Optional<CarteContribuable> findByMatriculeUnique(String matriculeUnique);

    // Recherche par numéro de carte
    Optional<CarteContribuable> findByNumeroCarte(String numeroCarte);

    // Cartes par statut
    List<CarteContribuable> findByStatus(CarteStatus status);

    // Cartes expirant avant une date
    List<CarteContribuable> findByDateExpirationBefore(LocalDateTime date);

    // Cartes émises dans une période
    List<CarteContribuable> findByDateEmissionBetween(LocalDateTime debut, LocalDateTime fin);

    // Cartes non synchronisées
    List<CarteContribuable> findBySyncedFalse();

    // Compteur par statut
    long countByStatus(CarteStatus status);

    // Cartes actives d'un contribuable (query custom pour gérer le cas ACTIVE)
    @Query("SELECT c FROM CarteContribuable c WHERE c.contribuable.id = :contribuableId AND c.status = :status")
    Optional<CarteContribuable> findActiveByContribuable(@Param("contribuableId") Long contribuableId, @Param("status") CarteStatus status);

    // Cartes récentes (limitées)
    @Query("SELECT c FROM CarteContribuable c ORDER BY c.dateEmission DESC LIMIT :limit")
    List<CarteContribuable> findRecentCartes(@Param("limit") int limit);
}
