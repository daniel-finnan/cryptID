-- Verify cryptID:function_insert_equivalent_token on pg

BEGIN;

SELECT pg_catalog.has_function_privilege('postgres', 'dtif.insert_equivalent_token(JSONB)', 'EXECUTE');

ROLLBACK;
