package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Auditable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.NoRepositoryBean;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@NoRepositoryBean
public interface BaseRepository<T extends Auditable, ID> extends JpaRepository<T, ID> {

    // Récupérer uniquement les éléments actifs (non supprimés)
    @Override
    @Query("SELECT e FROM #{#entityName} e WHERE e.deletedAt IS NULL")
    List<T> findAll();

    @Override
    @Query("SELECT e FROM #{#entityName} e WHERE e.id = ?1 AND e.deletedAt IS NULL")
    Optional<T> findById(ID id);

    // Inclure les éléments supprimés
    @Query("SELECT e FROM #{#entityName} e")
    List<T> findAllIncludingDeleted();

    @Query("SELECT e FROM #{#entityName} e WHERE e.id = ?1")
    Optional<T> findByIdIncludingDeleted(ID id);

    // Suppression logique
    @Modifying
    @Transactional
    @Query("UPDATE #{#entityName} e SET e.deletedAt = CURRENT_TIMESTAMP, e.deletedBy = ?2, e.isActive = false WHERE e.id = ?1")
    void deleteLogical(ID id, String deletedBy);

    // Restauration
    @Modifying
    @Transactional
    @Query("UPDATE #{#entityName} e SET e.deletedAt = NULL, e.deletedBy = NULL, e.isActive = true WHERE e.id = ?1")
    void restore(ID id);

    // Compter les éléments actifs
    @Query("SELECT COUNT(e) FROM #{#entityName} e WHERE e.deletedAt IS NULL")
    long countActive();

    // Compter tous les éléments y compris supprimés
    @Query("SELECT COUNT(e) FROM #{#entityName} e")
    long countAll();
}
