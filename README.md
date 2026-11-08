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

- **Date and legal instrument of creation**: the law, decree or regional law that created the unit, or whether it dates from the Independence era.
- **Presence in each census**: whether the unit existed at the date of the 1981, 1993, 2007, 2017 and 2025 censuses. This coding reproduces exactly INEI's national counts of provinces and districts for every census, and its department counts at 31/12/2021.

The construction steps and sources are documented in the vignette `vignette("construction", package = "ubigeocensos")`.

## Status

| Step | Description | Status |
|---|---|---|
| 1 | Units in the 2025 Census (25 departments, 196 provinces, 1,892 districts) | ✅ |
| 2 | Creation date and legal instrument | ✅ All units but four (Callao province; Urcos, Anco and Magdalena de Cao districts), from INEI 1997–2022, JNE, Congreso and PCM-SDOT (GEOSDOT) |
| 3 | Presence in the 1981, 1993, 2007 and 2017 censuses | ✅ (matches INEI national counts, and department counts at 31/12/2021) |
| 4 | Territorial origin of districts created 1981–2021 | ✅ (`inei_district_origins`) |
| 5 | Creation dates of districts that existed before 1981 (INEI 1999, other 24 departments) | ⏳ |
| 6 | Crosswalk for recoded units, checked against each census's UBIGEO list | ⏳ |

## Data structure

### For Departments (`departments`)

| Field | Description |
|---|---|
| inei | UBIGEO (INEI, 2025 Census) |
| department | Name of the department |
| created_date | Date of creation (`NA` when only the year is known) |
| created_year | Year of creation |
| legal_instrument | Type and number of the legal instrument of creation |
| independence_era | `TRUE` if the unit dates from the Independence era (no instrument) |
| creation_source | Source(s) of the creation data (`INEI 1997`, `INEI 1999`, `INEI 2020`, `INEI 2022`, `JNE 2021`, `Congreso 2025`, `GEOSDOT`) |
| note | Warnings about the data |
| census_1981 … census_2025 | 1 if the unit existed at the census date, 0 if it was created afterwards |

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

### Source tables

| Dataset | Content | Source |
|---|---|---|
| `inei1997_departments` | 25 departments: instrument and date of creation, surface and population (1997), footnotes on renamings | INEI 1997 |
| `inei1997_provinces` | 11 provinces created 1990–97: law number and date, legal capital and its category, 1997 region | INEI 1997 |
| `inei1997_districts` | 34 districts created 1990–97: law number and date, legal capital and its category, 1997 region | INEI 1997 |
| `division_counts` | Number of departments, provinces and districts at each census (national and by department), 1940–2017, and at 31/12/2019 and 31/12/2021 | INEI 2020; INEI 2022 |
| `inei_provinces_created` | 43 provinces created 1981–2021: law, publication date, UBIGEO | INEI 2020; INEI 2022 |
| `inei_districts_created` | 210 districts created 1981–2021: law, year | INEI 2020; INEI 2022 |
| `inei_district_origins` | Districts each new district was carved from ("procedencia territorial") | INEI 2020; INEI 2022 |
| `geosdot_norms` | 4,788 legal instruments of creation, modification and cancellation of 2,091 departments, provinces and districts | PCM-SDOT (GEOSDOT) |
| `districts_created_2020_2025` | 18 districts created 2020–2025: law, exact date | JNE 2021; Congreso 2025 |

Census presence refers to the unit as identified in 2025. A district later split from another still counts as present in earlier censuses, with a larger territory; units abolished before 2025 are not included. See `vignette("construction", package = "ubigeocensos")`.

## Rebuilding the data

```r
# needs readxl, pdftools, stringi, tibble, usethis
source("data-raw/make_datasets.R")
devtools::document()
```

## Sources

- **INEI 2025**: Instituto Nacional de Estadística e Informática (2025). *Censos Nacionales 2025: listado de ubigeos*. Lima: INEI.
- **INEI 1997**: Instituto Nacional de Estadística e Informática (1997). *Compendio Estadístico 1996-97*. Lima: INEI. Cuadros 1.16 ("Superficie, población, densidad poblacional y dispositivo de creación, según departamento, 1997"), 1.18 and 1.19 ("Categoría de la capital legal y ley de creación de nuevas provincias / nuevos distritos, 1990 - 97"). <https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/LIB0170/n00.htm>
- **INEI 1999**: Instituto Nacional de Estadística e Informática (1999). *Perú: Directorio Nacional de Municipalidades Provinciales y Distritales 1999*. Lima: INEI. <https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/Lib0362/indice.htm>
- **INEI 2020**: Instituto Nacional de Estadística e Informática (2020). *Perú: Proyecciones de Población por Departamento, Provincia y Distrito, 2018 - 2020*. Boletín Especial Nº 26. Lima: INEI. Chapter 2, "División política y administrativa al 31 de diciembre del 2019". <https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1715/libro.pdf>
- **INEI 2022**: Instituto Nacional de Estadística e Informática (2022). *Perú: Proyecciones de Población Total según Departamento, Provincia y Distrito, 2018 – 2022*. Boletín Especial Nº 27. Lima: INEI. Anexo 2, "División política y administrativa al 31 de diciembre de 2021". <https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1860/libro.pdf>
- **GEOSDOT**: Presidencia del Consejo de Ministros, Secretaría de Demarcación y Organización Territorial (2026). *Sistema de consultas de información de naturaleza demarcatoria (GEOSDOT)*, módulo Circunscripciones. Consulted on 08/11/2026. <https://geosdot.servicios.gob.pe/consultas/#/circunscripcion>
- **JNE 2021**: Jurado Nacional de Elecciones (2021). *Resolución N.° 0913-2021-JNE*, 22 de noviembre de 2021. <https://portal.jne.gob.pe/portal_documentos/files/72803f45-044d-4c92-841b-6b2dbe8efc0a.pdf>
- **Congreso 2025**: Congreso de la República (2025). *Leyes de creación de distritos*. Área de Estadística Parlamentaria. <https://www.congreso.gob.pe/Docs/DGP/GestionInformacionEstadistica/files/publicaciones-25/leyes-declarativas-creaci%C3%93n-distritos.pdf>

## License

MIT
