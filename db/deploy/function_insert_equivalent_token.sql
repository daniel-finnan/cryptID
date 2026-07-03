-- Deploy cryptID:function_insert_equivalent_token to pg

BEGIN;

CREATE OR REPLACE FUNCTION dtif.insert_equivalent_token (json_input JSONB)
	RETURNS void
	LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO dtif.staging_json (json_record) 
	VALUES (json_input);
	INSERT INTO dtif.token
		SELECT
			-- Header
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			(json_record -> 'Header' ->> 'DTIType')::dtif.DTI_TYPE AS dti_type,
			(json_record -> 'Header' ->> 'templateVersion')::dtif.TEMPLATE_VERSION AS template_version,
			--Informative
			(json_record -> 'Informative' ->> 'LongName')::TEXT AS long_name,
			(json_record -> 'Informative' ->> 'OrigLangLongName')::TEXT AS orig_lang_long_name,
			(json_record -> 'Informative' ->> 'UnitMultiplier')::TEXT AS unit_multiplier,
			(json_record -> 'Informative' ->> 'IssuerName')::TEXT AS issuer_name,
			(json_record -> 'Informative' ->> 'IssuerOriginalLanguageLongName')::TEXT AS issuer_original_language_long_name,
			(json_record -> 'Informative' ->> 'MaintainerName')::TEXT AS issuer_name,
			(json_record -> 'Informative' ->> 'MaintainerOriginalLanguageLongName')::TEXT AS maintainer_original_language_long_name,
			--Metadata
			(json_record -> 'Metadata' ->> 'recVersion')::INTEGER AS rec_version,
			(json_record -> 'Metadata' ->> 'recDateTime')::TIMESTAMP AS rec_date_time,
			(json_record -> 'Metadata' ->> 'Provisional')::BOOL AS provisional,
			(json_record -> 'Metadata' ->> 'Private')::BOOL AS private,
			(json_record -> 'Metadata' ->> 'Disputed')::BOOL AS disputed,
			(json_record -> 'Metadata' ->> 'Deleted')::BOOL AS deleted,
			(json_record -> 'Metadata' ->> 'statusDate')::TIMESTAMP AS status_date,
			(json_record -> 'Metadata' ->> 'Certified')::BOOL AS certified,
			(json_record -> 'Metadata' ->> 'Issued')::BOOL AS issued,
			(json_record -> 'Metadata' ->> 'Lapsed')::BOOL AS lapsed,
			(json_record -> 'Metadata' ->> 'Retired')::BOOL AS retired
		FROM dtif.staging_json;
	--Informative
	WITH cte_issuer_identifier AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			json_record -> 'Informative' -> 'IssuerIdentifiers' AS issuer_identifiers
		FROM dtif.staging_json
	)
	INSERT INTO dtif.issuer_identifier (dti, issuer_identifier_type, issuer_identifier_value)
		SELECT
			dti,
			(jsonb_array_elements(issuer_identifiers) ->> 'IssuerIdentifierType')::dtif.ISSUER_IDENTIFIER_TYPE AS issuer_identifier_type,
			(jsonb_array_elements(issuer_identifiers) ->> 'IssuerIdentifierValue')::TEXT AS issuer_identifier_value
		FROM cte_issuer_identifier;
	WITH cte_maintainer_identifier AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			json_record -> 'Informative' -> 'MaintainerIdentifiers' AS maintainer_identifiers
		FROM dtif.staging_json
	)
	INSERT INTO dtif.maintainer_identifier (dti, maintainer_identifier_type, maintainer_identifier_value)
		SELECT
			dti,
			(jsonb_array_elements(maintainer_identifiers) ->> 'MaintainerIdentifierType')::dtif.MAINTAINER_IDENTIFIER_TYPE AS maintainer_identifier_type,
			(jsonb_array_elements(maintainer_identifiers) ->> 'MaintainerIdentifierValue')::TEXT AS maintainer_identifier_value
		FROM cte_maintainer_identifier;
	WITH cte_short_name AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			json_record -> 'Informative' -> 'ShortNames' AS short_names
		FROM dtif.staging_json
	)
	INSERT INTO dtif.short_name (dti, short_name, orig_lang_short_name)
		SELECT
			dti,
			(jsonb_array_elements(short_names) ->> 'ShortName')::TEXT AS short_name,
			(jsonb_array_elements(short_names) ->> 'OrigLangShortName')::TEXT AS orig_lang_short_name
		FROM cte_short_name;
	WITH cte_digital_asset_external_identifier AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			json_record -> 'Informative' -> 'DigitalAssetExternalIdentifiers' AS digital_asset_external_identifiers
		FROM dtif.staging_json
	)
	INSERT INTO dtif.digital_asset_external_identifier (dti, digital_asset_external_identifier_type, digital_asset_external_identifier_value)
		SELECT
			dti,
			(jsonb_array_elements(digital_asset_external_identifiers) ->> 'DigitalAssetExternalIdentifierType')::dtif.DIGITAL_ASSET_EXTERNAL_IDENTIFIER_TYPE AS digital_asset_external_identifier_type,
			(jsonb_array_elements(digital_asset_external_identifiers) ->> 'DigitalAssetExternalIdentifierValue')::TEXT AS digital_asset_external_identifier_value
		FROM cte_digital_asset_external_identifier;
	WITH cte_dti_external_identifier AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS dti,
			json_record -> 'Informative' -> 'DTIExternalIdentifiers' AS dti_external_identifiers
		FROM dtif.staging_json
	)
	INSERT INTO dtif.dti_external_identifier (dti, dti_external_identifier_type, external_identifier_value)
		SELECT
			dti,
			(jsonb_array_elements(dti_external_identifiers) ->> 'DTIExternalIdentifierType')::dtif.DTI_EXTERNAL_IDENTIFIER_TYPE AS dti_external_identifier_type,
			(jsonb_array_elements(dti_external_identifiers) ->> 'ExternalIdentifierValue')::TEXT AS external_identifier_value
		FROM cte_dti_external_identifier;
	--Normative
	WITH cte_equivalent_digital_token_group AS (
		SELECT
			(json_record -> 'Header' ->> 'DTI')::VARCHAR(9) AS equivalent_digital_token_group_dti,
			json_record -> 'Normative' -> 'EquivalentDigitalTokenGroupDTI' AS auxiliary_dtis
		FROM dtif.staging_json
	)
	INSERT INTO dtif.equivalent_digital_token_group (equivalent_digital_token_group_dti, auxiliary_dti)
		SELECT
			equivalent_digital_token_group_dti::VARCHAR(9) AS equivalent_digital_token_group_dti,
			(jsonb_array_elements(auxiliary_dtis)) #>> '{}' AS auxiliary_dti
		FROM cte_equivalent_digital_token_group;
	DELETE FROM dtif.staging_json;
END;
$$;

COMMIT;
