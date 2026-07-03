-- Verify cryptID:schema on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('dtif', 'USAGE');

ROLLBACK;
