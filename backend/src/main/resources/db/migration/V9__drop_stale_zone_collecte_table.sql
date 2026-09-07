-- V9: Remove leftovers from the V6 rename of zone_collecte -> zone
-- An older schema recreated an empty zone_collecte table along with foreign keys
-- pointing to it. Rows inserted into agent_zone/contribuable/taxecollect/transaction
-- referencing an existing zone(id) failed because the same zone_id was validated
-- against the empty zone_collecte table.
-- Every affected table already carries the correct foreign key towards zone(id),
-- so the stale constraints and the empty table can be dropped safely.

ALTER TABLE IF EXISTS agent_zone DROP CONSTRAINT IF EXISTS fkfnmwv6k9wbx6bjsjxif9coi6r;
ALTER TABLE IF EXISTS contribuable DROP CONSTRAINT IF EXISTS fk574g87q50hjom0t5t3jtp5gin;
ALTER TABLE IF EXISTS taxecollect DROP CONSTRAINT IF EXISTS fk5agubqwmofon3vw87fo36mgb1;
ALTER TABLE IF EXISTS transaction DROP CONSTRAINT IF EXISTS fksonkyykx2ddi7tc14ylmepxvd;

DROP TABLE IF EXISTS zone_collecte;
