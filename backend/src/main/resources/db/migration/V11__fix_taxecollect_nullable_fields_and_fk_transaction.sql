-- Rendre nullable les champs de paiement de taxecollect (une taxe impayée n'a pas encore de paiement)
ALTER TABLE taxecollect ALTER COLUMN date_paiement DROP NOT NULL;
ALTER TABLE taxecollect ALTER COLUMN mode_paiement DROP NOT NULL;

-- Ajouter une contrainte unique sur numero_recu
ALTER TABLE taxecollect ADD CONSTRAINT uk_taxecollect_numero_recu UNIQUE (numero_recu);

-- Ajouter la FK transaction -> taxecollect
ALTER TABLE transaction ADD COLUMN taxe_collect_id BIGINT;
ALTER TABLE transaction ADD CONSTRAINT fk_transaction_taxecollect
    FOREIGN KEY (taxe_collect_id) REFERENCES taxecollect(id);
