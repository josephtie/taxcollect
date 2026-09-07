package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;

@Component
public class PaymentStateMachine {

    private final Map<StatutTransaction, Set<StatutTransaction>> validTransitions = new EnumMap<>(StatutTransaction.class);

    public PaymentStateMachine() {
        // Flux agent espèces/offline existant
        validTransitions.put(StatutTransaction.EN_ATTENTE, EnumSet.of(StatutTransaction.VALIDEE, StatutTransaction.SYNCHRONISEE, StatutTransaction.ANNULEE, StatutTransaction.EN_ERREUR));
        validTransitions.put(StatutTransaction.SYNCHRONISEE, EnumSet.of(StatutTransaction.VALIDEE, StatutTransaction.EN_ERREUR));
        validTransitions.put(StatutTransaction.VALIDEE, EnumSet.of(StatutTransaction.ANNULEE, StatutTransaction.REFUNDED, StatutTransaction.PARTIALLY_REFUNDED));

        // Flux paiement digital
        validTransitions.put(StatutTransaction.INITIATED, EnumSet.of(StatutTransaction.PENDING, StatutTransaction.FAILED, StatutTransaction.EXPIRED));
        validTransitions.put(StatutTransaction.PENDING, EnumSet.of(StatutTransaction.SUCCESS, StatutTransaction.FAILED, StatutTransaction.EXPIRED, StatutTransaction.ANNULEE));
        validTransitions.put(StatutTransaction.SUCCESS, EnumSet.of(StatutTransaction.REFUNDED, StatutTransaction.PARTIALLY_REFUNDED));
        validTransitions.put(StatutTransaction.FAILED, EnumSet.of(StatutTransaction.INITIATED));
        validTransitions.put(StatutTransaction.EXPIRED, EnumSet.of(StatutTransaction.INITIATED));
        validTransitions.put(StatutTransaction.REFUNDED, EnumSet.noneOf(StatutTransaction.class));
        validTransitions.put(StatutTransaction.PARTIALLY_REFUNDED, EnumSet.of(StatutTransaction.REFUNDED));
        validTransitions.put(StatutTransaction.ANNULEE, EnumSet.noneOf(StatutTransaction.class));
        validTransitions.put(StatutTransaction.EN_ERREUR, EnumSet.of(StatutTransaction.EN_ATTENTE, StatutTransaction.INITIATED));
    }

    public boolean canTransition(StatutTransaction from, StatutTransaction to) {
        Set<StatutTransaction> allowed = validTransitions.get(from);
        return allowed != null && allowed.contains(to);
    }

    public void validateTransition(StatutTransaction from, StatutTransaction to) {
        if (!canTransition(from, to)) {
            throw new IllegalStateException(
                "Transition invalide: " + from + " → " + to + " n'est pas autorisée");
        }
    }
}
