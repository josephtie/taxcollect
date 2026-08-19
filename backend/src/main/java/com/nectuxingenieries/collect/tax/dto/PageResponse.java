package com.nectuxingenieries.collect.tax.dto;

import java.util.List;

/**
 * Réponse paginée standardisée pour l'API
 * @param <T> Type des données contenues
 */
public record PageResponse<T>(
    List<T> content,
    int page,
    int size,
    long totalElements,
    int totalPages,
    boolean first,
    boolean last
) {
    
    /**
     * Constructeur simplifié qui calcule first/last automatiquement
     */
    public PageResponse(List<T> content, int page, int size, long totalElements, int totalPages) {
        this(content, page, size, totalElements, totalPages, page == 0, page == totalPages - 1);
    }
    
    /**
     * Crée une réponse vide
     */
    public static <T> PageResponse<T> empty(int page, int size) {
        return new PageResponse<>(List.of(), page, size, 0, 0, true, true);
    }
}
