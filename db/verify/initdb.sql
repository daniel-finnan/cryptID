-- Verify cryptID:initdb on pg

BEGIN;

SELECT pg_catalog.has_table_privilege('dtif.fork', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.issuer_identifier', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.maintainer_identifier', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.auxiliary_token', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.ledger', 'SELECT');

SELECT pg_catalog.has_table_privilege('dtif.short_name', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.digital_asset_external_identifier', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.dti_external_identifier', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.equivalent_digital_token_group', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.token', 'SELECT');
SELECT pg_catalog.has_table_privilege('dtif.staging_json', 'SELECT');

SELECT pg_catalog.has_type_privilege('dtif.DLT_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.TEMPLATE_VERSION', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.HASH_ALGORITHM', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.DTI_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.ISSUER_IDENTIFIER_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.MAINTAINER_IDENTIFIER_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.DIGITAL_ASSET_EXTERNAL_IDENTIFIER_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.DTI_EXTERNAL_IDENTIFIER_TYPE', 'USAGE');
SELECT pg_catalog.has_type_privilege('dtif.AUXILIARY_MECHANISM', 'USAGE');

ROLLBACK;
