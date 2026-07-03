-- Verify cryptID:function_insert_ledger on pg

BEGIN;

SELECT pg_catalog.has_function_privilege('postgres', 'dtif.insert_ledger(JSONB)', 'EXECUTE');

ROLLBACK;
