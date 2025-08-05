package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Contribuable;
import org.springframework.data.jpa.domain.Specification;

public class ContribuableSpecifications {

    public static Specification<Contribuable> hasNom(String nom) {
        return (root, query, cb) ->
                nom == null ? cb.conjunction()
                        : cb.like(cb.lower(root.get("nom")),
                        "%" + nom.toLowerCase() + "%");
    }

    public static Specification<Contribuable> hasPrenom(String prenom) {
        return (root, query, cb) ->
                prenom == null ? cb.conjunction()
                        : cb.like(cb.lower(root.get("prenom")),
                        "%" + prenom.toLowerCase() + "%");
    }
}

