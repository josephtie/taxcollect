package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.Auditable;
import com.nectuxingenieries.collect.tax.repositories.BaseRepository;
import com.nectuxingenieries.collect.tax.security.LogicalDeletionPermissions;
import com.nectuxingenieries.collect.tax.services.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.function.Function;

/**
 * Implémentation de base avec suppression logique
 */
public abstract class BaseServiceImpl<T extends Auditable, ID, DTO, REPO extends BaseRepository<T, ID>> 
        implements BaseService<T, ID, DTO> {

    protected final REPO repository;
    protected final Function<DTO, T> toEntityMapper;
    protected final Function<T, DTO> toDtoMapper;
    protected final LogicalDeletionPermissions permissions;

    @Autowired
    public BaseServiceImpl(REPO repository, Function<DTO, T> toEntityMapper, Function<T, DTO> toDtoMapper, LogicalDeletionPermissions permissions) {
        this.repository = repository;
        this.toEntityMapper = toEntityMapper;
        this.toDtoMapper = toDtoMapper;
        this.permissions = permissions;
    }

    @Override
    @Transactional
    public DTO create(DTO dto) {
        T entity = toEntityMapper.apply(dto);
        T saved = repository.save(entity);
        return toDtoMapper.apply(saved);
    }

    @Override
    @Transactional
    public DTO update(ID id, DTO dto) {
        T existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entité non trouvée avec l'ID: " + id));
        
        // Pour la mise à jour, nous devons mapper manuellement les champs
        // Cette méthode doit être implémentée dans les classes concrètes
        updateEntityFromDto(existing, dto);
        
        return toDtoMapper.apply(repository.save(existing));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<DTO> findById(ID id) {
        return repository.findById(id).map(toDtoMapper);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DTO> findAll() {
        return repository.findAll()
                .stream()
                .map(toDtoMapper)
                .toList();
    }

    @Override
    @Transactional
    public void delete(ID id) {
        // Vérifier les permissions de suppression
        if (!permissions.canDelete()) {
            throw new SecurityException("Vous n'avez pas les permissions de supprimer cette entité");
        }

        T entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entité non trouvée avec l'ID: " + id));
        
        String currentUser = getCurrentUser();
        repository.deleteLogical(id, currentUser);
    }

    @Override
    @Transactional
    public void restore(ID id) {
        // Vérifier les permissions de restauration
        T entity = repository.findByIdIncludingDeleted(id)
                .orElseThrow(() -> new RuntimeException("Entité non trouvée avec l'ID: " + id));

        if (!permissions.canRestore(entity.getDeletedBy())) {
            throw new SecurityException("Vous n'avez pas les permissions de restaurer cette entité");
        }
        
        repository.restore(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DTO> findAllIncludingDeleted() {
        // Vérifier les permissions pour voir les entités supprimées
        if (!permissions.canViewDeleted()) {
            throw new SecurityException("Vous n'avez pas les permissions de voir les entités supprimées");
        }

        return repository.findAllIncludingDeleted()
                .stream()
                .map(toDtoMapper)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public long countActive() {
        return repository.countActive();
    }

    @Override
    @Transactional(readOnly = true)
    public long countAll() {
        // Vérifier les permissions pour voir les entités supprimées
        if (!permissions.canViewDeleted()) {
            return repository.countActive();
        }
        return repository.countAll();
    }

    /**
     * Obtient l'utilisateur actuel via le service de permissions
     */
    protected String getCurrentUser() {
        return permissions.getCurrentUser();
    }

    /**
     * Méthode à implémenter dans les classes concrètes pour mettre à jour une entité à partir d'un DTO
     */
    protected abstract void updateEntityFromDto(T entity, DTO dto);
}
