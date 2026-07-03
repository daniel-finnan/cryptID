-- Deploy cryptID:initdb to pg

BEGIN;

-- Types
-- =====
CREATE TYPE dtif.DLT_TYPE AS ENUM ('1','0');
-- 1 = "Blockchain"
-- 0 = "Other"
CREATE TYPE dtif.TEMPLATE_VERSION AS ENUM ('v2.0.0');
CREATE TYPE dtif.HASH_ALGORITHM AS ENUM(
	'BLAKE2 (Base58)',
	'BLAKE-256',
	'BLAKE2b-256',
	'BLAKE2b-256 (0x)',
	'BLAKE2s-256',
	'Double SHA-256',
	'Keccak-256',
	'LISK SPEC',
	'LOST',
	'Poseidon Hash',
	'SHAKE-256',
	'SHA-224 (160Bits)',
	'SHA3-256',
	'SHA3-256 (Base58)',
	'SHA-256 (Decimals)',
	'SHA-256',
	'SHA-256 (Base32)',
	'SHA-256 (Base58)',
	'SHA-256 (Base64url)',
	'SHA-384',
	'SHA-512Half',
	'SHA512-256 (Base16)',
	'SHA512/256 (Base32)',
	'SteemHash',
	'VRF Signature'
);
CREATE TYPE dtif.DTI_TYPE AS ENUM ('0','1', '2', '3', '4');
-- 0 = "Auxiliary Digital Token"
-- 1 = "Protocol Digital Token"
-- 2 = "Equivalent Digital Token Group" *** Duplicating this twice
-- 3 = "Equivalent Digital Token Group" *** '3' in schema, but '2' in actual records
-- 4 = "Non-Fungible Token"
CREATE TYPE dtif.ISSUER_IDENTIFIER_TYPE AS ENUM ('LEI');
CREATE TYPE dtif.MAINTAINER_IDENTIFIER_TYPE AS ENUM ('LEI');
CREATE TYPE dtif.DIGITAL_ASSET_EXTERNAL_IDENTIFIER_TYPE AS ENUM(
	'ISIN',
	'Cusip',
	'SEDOL',
	'RIC',
	'CCY',
	'Country code',
	'FIGI',
	'LEI'
);
CREATE TYPE dtif.DTI_EXTERNAL_IDENTIFIER_TYPE AS ENUM ('ITIN');
CREATE TYPE dtif.AUXILIARY_MECHANISM AS ENUM (
	'ATS',
	'ASA',
	'ARC-20',
	'BEP-2',
	'BEP-20',
	'BIP-32',
	'BRC-20',
	'BRC 2.0',
	'Cardano Smart Contract',
	'CIS-2',
	'CRC20',
	'CW20',
	'DOG-20',
	'ERC-20',
	'Escrow',
	'ESDT',
	'EOSIO.TOKEN',
	'Euroclear D-FMI',
	'FA2',
	'FT',
	'Fungible Asset',
	'Fungible CashToken',
	'GSDAP',
	'HIP-1',
	'HRC20',
	'HRC-20',
	'HTS',
	'HSBC Orion',
	'IBC Coin',
	'ICRC-1',
	'IOU',
	'Jetton',
	'KIP-7',
	'KIP-20',
	'Lightning',
	'LiquidAsset',
	'Move Coin',
	'Native Attribute',
	'Native Coin',
	'NEP-5',
	'NEP-17',
	'NEP-141',
	'OEP-4',
	'OMNI',
	'PLT', -- Added this manually, for Concordium, Protocol-Level Tokens (PLT)
	'Polkadot Asset',
	'Rune',
	'SEP-1',
	'SEP20',
	'SIP-10',
	'SORA Token',
	'SPL-Token',
	'SUI Coin',
	'StatemineAsset',
	'StatemintAsset',
	'TAI2',
	'TIP-3',
	'TRC-10',
	'TRC-20',
	'SDX',
	'SLP Token',
	'WORLDLINE',
	'WRC-20',
	'WSC',
	'Vite Tokens',
	'VRC20',
	'VRC21',
	'VRC25',
	'XRC20',
	'ZRC-2'
);

-- Staging table
-- =============
CREATE TABLE dtif.staging_json (
	json_record JSONB
);

-- Main tables
-- ===========
CREATE TABLE dtif.ledger (
	-- Header
	-- ======
	dli VARCHAR(9) PRIMARY KEY,
	dlt_type dtif.DLT_TYPE NOT NULL,
	template_version dtif.TEMPLATE_VERSION NOT NULL,
	
	-- Informative
	-- ===========
	long_name TEXT NOT NULL,
	orig_lang_long_name TEXT,
	url TEXT,
	block_number_offset INTEGER,
	public_distributed_ledger_indication BOOL,
	-- =========================================
	-- IssuerIdentifiers & MaintainerIdentifiers
	-- stored in another table
	-- =========================================
	issuer_name TEXT,
	issuer_original_language_long_name TEXT,
	maintainer_name TEXT,
	maintainer_original_language_long_name TEXT,

	-- Normative
	-- =========
	anchor_block_hash TEXT, --NZ27XDL11, XFG5G4CF9 Lightning Network, Hedera Hashgraph, contains null, despite this being conditionally required
	anchor_block_hash_algorithm dtif.HASH_ALGORITHM, --NZ27XDL11, XFG5G4CF9 Lightning Network, Hedera Hashgraph, contains null, despite this being conditionally required
	anchor_block_utc_timestamp TIMESTAMP,
	anchor_block_height INTEGER NOT NULL,
	-- =============================
	-- Forks stored in another table
	-- =============================

	-- Metadata
	-- ========
	rec_version INTEGER NOT NULL,
	rec_date_time TIMESTAMP NOT NULL,
	provisional BOOL,
	private BOOL,
	disputed BOOL,
	deleted BOOL,
	certified BOOL,
	issued BOOL,
	lapsed BOOL,
	retired BOOL
);
-- Equivalent / Auxiliary
CREATE TABLE dtif.token (
	-- Header
	-- ======	
	dti VARCHAR(9) PRIMARY KEY,
	dti_type dtif.DTI_TYPE NOT NULL,
	template_version dtif.TEMPLATE_VERSION NOT NULL,
	-- Informative
	-- ===========
	long_name TEXT NOT NULL,
	orig_lang_long_name TEXT,
	-- ======================================================================================
	-- ShortNames, DigitalAssetExternalIdentifiers, DTIExternalIdentifiers, IssuerIdentifiers
	-- MaintainerIdentifiers, EquivalentDigitalTokenGroupDTI stored in another table
	-- ======================================================================================
	unit_multiplier TEXT,
	issuer_name TEXT,
	issuer_original_language_long_name TEXT,
	maintainer_name TEXT,
	maintainer_original_language_long_name TEXT,
	rec_version INTEGER NOT NULL,
	rec_date_time TIMESTAMP NOT NULL,
	provisional BOOL,
	private BOOL,
	disputed BOOL,
	deleted BOOL,
	status_date TIMESTAMP,
	certified BOOL,
	issued BOOL,
	lapsed BOOL,
	retired BOOL
);
CREATE TABLE dtif.fork (
	fork_reference_dli VARCHAR(9) REFERENCES dtif.ledger (dli) NOT NULL,
	fork_block_height INTEGER NOT NULL,
	fork_block_utc_timestamp TIMESTAMP NOT NULL,
	fork_block_hash TEXT PRIMARY KEY, 
	-- Linking this to enum, but actually stored as string in schema
	fork_block_hash_algorithm dtif.HASH_ALGORITHM NOT NULL,
	consensus_mechanism_change_response BOOL NOT NULL,
	digital_token_creation_response BOOL NOT NULL
);
CREATE TABLE dtif.issuer_identifier (
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	dti VARCHAR(9) REFERENCES dtif.token (dti), 
	dli VARCHAR(9) REFERENCES dtif.ledger (dli),
	issuer_identifier_type dtif.ISSUER_IDENTIFIER_TYPE NOT NULL,
	issuer_identifier_value TEXT NOT NULL
);
CREATE TABLE dtif.maintainer_identifier (
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	dti VARCHAR(9) REFERENCES dtif.token (dti), 
	dli VARCHAR(9) REFERENCES dtif.ledger (dli),
	maintainer_identifier_type dtif.MAINTAINER_IDENTIFIER_TYPE NOT NULL,
	maintainer_identifier_value TEXT NOT NULL
);
CREATE TABLE dtif.short_name(
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	short_name TEXT NOT NULL,
	orig_lang_short_name TEXT,
	dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL
);
CREATE TABLE dtif.digital_asset_external_identifier(
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL,
	digital_asset_external_identifier_type dtif.DIGITAL_ASSET_EXTERNAL_IDENTIFIER_TYPE NOT NULL,
	digital_asset_external_identifier_value TEXT NOT NULL
);
CREATE TABLE dtif.dti_external_identifier(
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL,
	dti_external_identifier_type dtif.DTI_EXTERNAL_IDENTIFIER_TYPE NOT NULL,
	external_identifier_value TEXT NOT NULL
);
CREATE TABLE dtif.equivalent_digital_token_group(
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	equivalent_digital_token_group_dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL,
	-- equivalent_digital_token_grouping_reasons Appears in Schema, but not in actual records
	auxiliary_dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL
);
CREATE TABLE dtif.auxiliary_token(
	id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	auxiliary_dti VARCHAR(9) REFERENCES dtif.token (dti) NOT NULL,
	auxiliary_mechanism dtif.AUXILIARY_MECHANISM NOT NULL,
	auxiliary_distributed_ledger VARCHAR(9) REFERENCES dtif.ledger (dli) NOT NULL,
	auxiliary_technical_reference TEXT NOT NULL
);

COMMIT;
