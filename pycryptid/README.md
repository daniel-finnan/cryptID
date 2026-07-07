# pyCryptID

Python API for CryptID database and digital token identification standards.

## Setup

TODO Outline installation of database schema.

Requires `.env` file in the root directory containing the following environment variables:

```
PG_USER=foo
PG_PASSWORD=bar
PG_HOST=localhost
PG_DATABASE=cryptID
PG_PORT=5432

DTIF_TOKENS=./data/json/tokens/
DTIF_LEDGERS=./data/json/ledgers/
```

The following directory structure is suggested for storage of `json` files downloaded manually from the [DTIF registry](https://registry.dtif.org).

```
root/
├── .env
├── data/
│   └── json/
│       ├── tokens/
│       └── ledgers/
```
