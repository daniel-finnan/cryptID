-- Revert cryptID:function_insert_auxiliary_token from pg

BEGIN;

DROP FUNCTION dtif.insert_auxiliary_token;

COMMIT;
