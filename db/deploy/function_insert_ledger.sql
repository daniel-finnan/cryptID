-- Deploy cryptID:function_insert_ledger to pg

BEGIN;

CREATE OR REPLACE FUNCTION dtif.insert_ledger (json_input JSONB)
	RETURNS void
	LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO dtif.staging_json (json_record) 
	VALUES (json_input);
	INSERT INTO dtif.ledger
		SELECT
			-- Header
			(json_record -> 'Header' ->> 'DLI')::VARCHAR(9) AS dli,
			(json_record -> 'Header' ->> 'DLTType')::dtif.DLT_TYPE AS dlt_type,
			(json_record -> 'Header' ->> 'templateVersion')::dtif.TEMPLATE_VERSION AS template_version,
			-- Informative
			(json_record -> 'Informative' ->> 'LongName')::TEXT AS long_name,
			(json_record -> 'Informative' ->> 'OrigLangLongName')::TEXT AS orig_lang_long_name,
			(json_record -> 'Informative' ->> 'URL')::TEXT AS url,
			(json_record -> 'Informative' ->> 'BlockNumberOffset')::INTEGER AS block_number_offset,
			(json_record -> 'Informative' ->> 'PublicDistributedLedgerIndication')::BOOL AS public_distributed_ledger_indication,
			--(json_record -> 'Informative' ->> 'IssuerIdentifiers')::TEXT[] AS issuer_identifiers,
			--(json_record -> 'Informative' ->> 'MaintainerIdentifiers')::TEXT[] AS maintainer_identifiers,
			(json_record -> 'Informative' ->> 'IssuerName')::TEXT AS issuer_name,
			(json_record -> 'Informative' ->> 'IssuerOriginalLanguageLongName')::TEXT AS issuer_original_language_long_name,
			(json_record -> 'Informative' ->> 'MaintainerName')::TEXT AS issuer_name,
			(json_record -> 'Informative' ->> 'MaintainerOriginalLanguageLongName')::TEXT AS maintainer_original_language_long_name,
			-- Normative
			(json_record -> 'Normative' ->> 'AnchorBlockHash')::TEXT AS anchor_block_hash,
			(json_record -> 'Normative' ->> 'AnchorBlockHashAlgorithm')::dtif.HASH_ALGORITHM AS anchor_block_hash_algorithm,
			(json_record -> 'Normative' ->> 'AnchorBlockUTCTimestamp')::TIMESTAMP AS anchor_block_utc_timestamp,
			(json_record -> 'Normative' ->> 'AnchorBlockHeight')::INTEGER AS anchor_block_height,
			-- Metadata
			(json_record -> 'Metadata' ->> 'recVersion')::INTEGER AS rec_version,
			(json_record -> 'Metadata' ->> 'recDateTime')::TIMESTAMP AS rec_date_time,
			(json_record -> 'Metadata' ->> 'Provisional')::BOOL AS provisional,
			(json_record -> 'Metadata' ->> 'Private')::BOOL AS private,
			(json_record -> 'Metadata' ->> 'Disputed')::BOOL AS disputed,
			(json_record -> 'Metadata' ->> 'Deleted')::BOOL AS deleted,
			(json_record -> 'Metadata' ->> 'Certified')::BOOL AS certified,
			(json_record -> 'Metadata' ->> 'Issued')::BOOL AS issued,
			(json_record -> 'Metadata' ->> 'Lapsed')::BOOL AS lapsed,
			(json_record -> 'Metadata' ->> 'Retired')::BOOL AS retired
	FROM dtif.staging_json;	
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
	WITH cte_fork AS (
		SELECT
			json_record -> 'Normative' -> 'Forks' AS forks
		FROM dtif.staging_json
	)
	INSERT INTO dtif.fork
		SELECT
			(jsonb_array_elements(forks) ->> 'ForkReferenceDLI')::VARCHAR(9) AS fork_reference_dli,
			(jsonb_array_elements(forks) ->> 'ForkBlockHeight')::INTEGER AS fork_block_height,
			(jsonb_array_elements(forks) ->> 'ForkBlockUTCTimestamp')::TIMESTAMP AS fork_block_utc_timestamp,
			(jsonb_array_elements(forks) ->> 'ForkBlockHash')::TEXT AS fork_block_hash,
			(jsonb_array_elements(forks) ->> 'ForkBlockHashAlgorithm')::dtif.HASH_ALGORITHM AS fork_block_hash_algorithm,
			(jsonb_array_elements(forks) ->> 'ConsensusMechanismChangeResponse')::BOOL AS consensus_mechanism_change_response,
			(jsonb_array_elements(forks) ->> 'DigitalTokenCreationResponse')::BOOL AS digital_token_creation_response
		FROM cte_fork;
	DELETE FROM dtif.staging_json;
END;
$$;

COMMIT;
