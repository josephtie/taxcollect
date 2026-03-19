package com.nectuxingenieries.collect.tax.services;


import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class GenericSpecifications {

    public static <T> Specification<T> fromMap(Map<String,String> filters) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            for (Map.Entry<String,String> entry : filters.entrySet()) {
                String field = entry.getKey();
                String value = entry.getValue();

                if (value != null && !value.isEmpty()) {
                    predicates.add(
                            cb.like(
                                    cb.lower(root.get(field).as(String.class)),
                                    "%" + value.toLowerCase() + "%" )
                    );
                }
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}


