-- Verify cryptID:function_insert_auxiliary_token on pg

BEGIN;

SELECT pg_catalog.has_function_privilege('postgres', 'dtif.insert_auxiliary_token(JSONB)', 'EXECUTE');

ROLLBACK;
