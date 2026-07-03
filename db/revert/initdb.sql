-- Revert cryptID:initdb from pg

BEGIN;

DROP TABLE dtif.fork;
DROP TABLE dtif.issuer_identifier;
DROP TABLE dtif.maintainer_identifier;
DROP TABLE dtif.auxiliary_token;
DROP TABLE dtif.ledger;

DROP TABLE dtif.short_name;
DROP TABLE dtif.digital_asset_external_identifier;
DROP TABLE dtif.dti_external_identifier;
DROP TABLE dtif.equivalent_digital_token_group;
DROP TABLE dtif.token;
DROP TABLE dtif.staging_json;

DROP TYPE dtif.DLT_TYPE;
DROP TYPE dtif.TEMPLATE_VERSION;
DROP TYPE dtif.HASH_ALGORITHM;
DROP TYPE dtif.DTI_TYPE;
DROP TYPE dtif.ISSUER_IDENTIFIER_TYPE;
DROP TYPE dtif.MAINTAINER_IDENTIFIER_TYPE;
DROP TYPE dtif.DIGITAL_ASSET_EXTERNAL_IDENTIFIER_TYPE;
DROP TYPE dtif.DTI_EXTERNAL_IDENTIFIER_TYPE;
DROP TYPE dtif.AUXILIARY_MECHANISM;

COMMIT;
