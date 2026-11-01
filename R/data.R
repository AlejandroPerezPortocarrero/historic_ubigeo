#' Departments of Peru (Census 2025)
#'
#' Departments in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation data and presence in each census. Includes the
#' Constitutional Province of Callao (`070000`).
#'
#' @format A tibble with 25 rows and 12 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{created_date}{Date of creation (`Date`)}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation (e.g. `"LEY 15246"`)}
#'   \item{independence_era}{`TRUE` if the source dates the unit to the Independence era (no instrument of creation)}
#'   \item{creation_source}{Source of the creation data}
#'   \item{note}{Warnings about the data (possible errors in the source)}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the unit was enumerated in that census, 0 if not, `NA` if not yet determined}
#' }
#' @source INEI, list of UBIGEO codes of the 2025 Census.
"departments"

#' Provinces of Peru (Census 2025)
#'
#' Provinces in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation data and presence in each census.
#'
#' @format A tibble with 196 rows and 13 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{province}{Name of the province}
#'   \item{created_date}{Date of creation (`Date`)}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation}
#'   \item{independence_era}{`TRUE` if the source dates the unit to the Independence era}
#'   \item{creation_source}{Source of the creation data}
#'   \item{note}{Warnings about the data}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the unit was enumerated in that census, 0 if not, `NA` if not yet determined}
#' }
#' @source INEI, list of UBIGEO codes of the 2025 Census.
"provinces"

#' Districts of Peru (Census 2025)
#'
#' Districts in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation date, legal instrument of creation and presence in each census.
#'
#' @format A tibble with 1,892 rows and 14 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{province}{Name of the province}
#'   \item{district}{Name of the district}
#'   \item{created_date}{Date of creation (`Date`)}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation (e.g. `"LEY 15246"`, `"DECRETO LEY 11059"`)}
#'   \item{independence_era}{`TRUE` if the source dates the district to the Independence era (no instrument of creation)}
#'   \item{creation_source}{Source of the creation data (currently `"INEI 1999"`)}
#'   \item{note}{Warnings about the data (possible errors in the source)}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the district was enumerated in that census, 0 if not, `NA` if not yet determined}
#' }
#' @source INEI, list of UBIGEO codes of the 2025 Census; INEI (1999), see
#'   [inei1999_districts].
"districts"

#' Legal creation of districts, INEI 1999
#'
#' Table X.3 of the INEI *Directorio Nacional de Municipalidades Provinciales y
#' Distritales 1999*, "Dispositivo legal de creación, población total,
#' superficie, densidad poblacional y población electoral de los distritos:
#' 1999", parsed and matched to the 2025 UBIGEO. Only departments whose
#' tables have been added to `data-raw/inei_lib0362/` are included.
#'
#' @format A tibble with one row per district and 14 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025) of the matching district}
#'   \item{dept}{Two-digit department code}
#'   \item{province_1999,district_1999}{Names as published in 1999}
#'   \item{instrument_type}{Type of legal instrument (LEY, DECRETO, DECRETO LEY, LEY REGIONAL)}
#'   \item{instrument_number}{Number of the instrument (`S/N` = unnumbered)}
#'   \item{date_text}{Date as published (e.g. `"02 ENE 1857"`, `"EPOCA INDEP."`)}
#'   \item{created_date}{Date of creation, ISO 8601 string}
#'   \item{independence_era}{`TRUE` if published as "EPOCA INDEP."}
#'   \item{pop_1998}{Total population at 30/06/1998}
#'   \item{surface}{Surface in km2}
#'   \item{pop_density_1998}{Population density (inhabitants per km2)}
#'   \item{electoral_pop_1999}{Electoral population at 04/01/1999 (RENIEC)}
#'   \item{note}{Warnings about the data}
#' }
#' @source Instituto Nacional de Estadística e Informática (1999). *Perú:
#'   Directorio Nacional de Municipalidades Provinciales y Distritales 1999*.
#'   Lima: INEI.
#'   <https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/Lib0362/indice.htm>
"inei1999_districts"
