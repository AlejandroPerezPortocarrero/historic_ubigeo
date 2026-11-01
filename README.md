# ubigeocensos (R package)

Departments, provinces and districts of Peru in the 1981, 1993, 2007, 2017 and 2025 population censuses, with their UBIGEO code and date of creation.

## Installation

This package is not on CRAN. You can install it with `devtools`:

```r
devtools::install_github("alejandroperezportocarrero/ubigeocensos")
```

## Note

If you would rather use CSV files, they are in [`inst/extdata/`](inst/extdata).

## Motivation

Peru's political-administrative division has changed a lot over the last four decades. Many districts and provinces were created between censuses, and some UBIGEO codes changed when a district moved to a new province. Linking census data across years (for example, building district panels for 1981–2025) therefore requires knowing **which units existed in each census** and **when each unit was created**.

The package uses the units of the **2025 Census** as its reference frame and their INEI UBIGEO as the identifier. For each unit it records:

- **Date and legal instrument of creation**: the law, decree or regional law that created the unit, or whether it dates from the Independence era. The current source is INEI (1999), *Perú: Directorio Nacional de Municipalidades Provinciales y Distritales 1999*.
- **Presence in each census**: whether the unit was enumerated in 1981, 1993, 2007, 2017 and 2025.

The construction steps and sources are documented in the vignette `vignette("construction", package = "ubigeocensos")`.

## Status

| Step | Description | Status |
|---|---|---|
| 1 | Units in the 2025 Census (25 departments, 196 provinces, 1,892 districts) | ✅ |
| 2 | Creation date and legal instrument | 🔄 Lima done (171 districts, INEI 1999) |
| 3 | Presence in the 2017 and 2007 censuses | ⏳ |
| 4 | Presence in the 1993 and 1981 censuses | ⏳ |
| 5 | Crosswalk for renamed, merged or recoded units | ⏳ |

## Data structure

### For Departments (`departments`)

| Field | Description |
|---|---|
| inei | UBIGEO (INEI, 2025 Census) |
| department | Name of the department |
| created_date | Date of creation |
| legal_instrument | Type and number of the legal instrument of creation |
| independence_era | `TRUE` if the unit dates from the Independence era (no instrument) |
| creation_source | Source of the creation data |
| note | Warnings about the data |
| census_1981 … census_2025 | 1 if enumerated in that census, 0 if not, `NA` if not yet determined |

The department count (25) includes the Constitutional Province of Callao (`070000`). Lima (`150000`) includes both Metropolitan Lima (province `150100`) and the provinces of Lima.

### For Provinces (`provinces`)

| Field | Description |
|---|---|
| inei | UBIGEO (INEI, 2025 Census) |
| department | Name of the department |
| province | Name of the province |
| created_date … census_2025 | As for departments |

### For Districts (`districts`)

| Field | Description |
|---|---|
| inei | UBIGEO (INEI, 2025 Census) |
| department | Name of the department |
| province | Name of the province |
| district | Name of the district |
| created_date … census_2025 | As for departments |

### Legal creation of districts, INEI 1999 (`inei1999_districts`)

The source table, parsed and matched to the 2025 UBIGEO.

| Field | Description |
|---|---|
| inei | UBIGEO (INEI, 2025 Census) of the matching district |
| dept | Two-digit department code |
| province_1999, district_1999 | Names as published in 1999 |
| instrument_type | LEY, DECRETO, DECRETO LEY, LEY REGIONAL |
| instrument_number | Number of the instrument (`S/N` = unnumbered) |
| date_text | Date as published |
| created_date | Date of creation (ISO 8601) |
| independence_era | `TRUE` if published as "EPOCA INDEP." |
| pop_1998 | Total population at 30/06/1998 |
| surface | Surface in km² |
| pop_density_1998 | Population density (inhabitants per km²) |
| electoral_pop_1999 | Electoral population at 04/01/1999 |
| note | Warnings about the data |

## Rebuilding the data

```r
source("data-raw/make_datasets.R")
devtools::document()
```

## Sources

- INEI. List of UBIGEO codes, 2025 Census.
- Instituto Nacional de Estadística e Informática (1999). *Perú: Directorio Nacional de Municipalidades Provinciales y Distritales 1999*. Lima: INEI. <https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/Lib0362/indice.htm>

## License

MIT
