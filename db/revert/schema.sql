-- Revert cryptID:schema from pg

BEGIN;

DROP SCHEMA dtif;

COMMIT;
