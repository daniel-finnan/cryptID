-- Revert cryptID:function_insert_ledger from pg

BEGIN;

DROP FUNCTION dtif.insert_ledger;

COMMIT;
