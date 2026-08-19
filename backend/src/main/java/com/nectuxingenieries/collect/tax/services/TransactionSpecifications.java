package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.Transaction;
import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TransactionSpecifications {

    public static Specification<Transaction> withFilters(
            LocalDateTime debut,
            LocalDateTime fin,
            Long agentId,
            String paymentMethod,
            StatutTransaction statut) {

        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (debut != null) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("dateCreation"), debut));
            }
            if (fin != null) {
                predicates.add(criteriaBuilder.lessThanOrEqualTo(root.get("dateCreation"), fin));
            }
            if (agentId != null) {
                predicates.add(criteriaBuilder.equal(root.get("agent").get("id"), agentId));
            }
            if (paymentMethod != null) {
                try {
                    ModePaiement mode = ModePaiement.valueOf(paymentMethod.toUpperCase());
                    predicates.add(criteriaBuilder.equal(root.get("modePaiement"), mode));
                } catch (IllegalArgumentException ignored) {
                }
            }
            if (statut != null) {
                predicates.add(criteriaBuilder.equal(root.get("statut"), statut));
            }

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}
