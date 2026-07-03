-- Revert cryptID:function_insert_equivalent_token from pg

BEGIN;

DROP FUNCTION dtif.insert_equivalent_token;

COMMIT;
