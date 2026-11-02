#' Departments of Peru (Census 2025)
#'
#' Departments in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation data and presence in each census. Includes the
#' Constitutional Province of Callao (`070000`).
#'
#' @format A tibble with 25 rows and 13 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{created_date}{Date of creation (`Date`). Law date for INEI 1999;
#'     publication date for INEI 2020 provinces; date listed by JNE 2021 /
#'     Congreso 2025. `NA` when only the year is known.}
#'   \item{created_year}{Year of creation}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation (e.g. `"LEY 15246"`)}
#'   \item{independence_era}{`TRUE` if the source dates the unit to the Independence era (no instrument of creation)}
#'   \item{creation_source}{Source(s) of the creation data: `"INEI 1999"`, `"INEI 2020"`, `"INEI 2022"`, `"JNE 2021"`, `"Congreso 2025"`}
#'   \item{note}{Warnings about the data (possible errors in the source)}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the unit
#'     existed at the census date, 0 if it was created afterwards. See Details.}
#' }
#' @details
#' **Census presence.** A unit is coded as present in a census when it had
#' been created before the census date (12/07/1981, 11/07/1993, 21/10/2007,
#' 22/10/2017). Units not listed as created between 1981 and 2025 in the
#' sources existed before the 1981 Census. The coding reproduces exactly the
#' national counts of provinces and districts published by INEI (2020) for each
#' census, and the national and department counts at 31/12/2021 published by
#' INEI (2022). Presence refers to the unit as identified in 2025: units that were
#' split, merged or moved between departments keep their 2025 identity, and
#' units abolished before 2025 are not included. See
#' `vignette("construction", package = "ubigeocensos")`.
#' @source INEI, list of UBIGEO codes of the 2025 Census; INEI (1999), see
#'   [inei1999_districts]; INEI (2020) and INEI (2022), see [division_counts];
#'   JNE (2021) and Congreso de la República (2025), see
#'   [districts_created_2020_2025].
"departments"

#' Provinces of Peru (Census 2025)
#'
#' Provinces in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation data and presence in each census.
#'
#' @format A tibble with 196 rows and 14 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{province}{Name of the province}
#'   \item{created_date}{Date of creation (`Date`). Law date for INEI 1999;
#'     publication date for INEI 2020 provinces; date listed by JNE 2021 /
#'     Congreso 2025. `NA` when only the year is known.}
#'   \item{created_year}{Year of creation}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation (e.g. `"LEY 15246"`)}
#'   \item{independence_era}{`TRUE` if the source dates the unit to the Independence era (no instrument of creation)}
#'   \item{creation_source}{Source(s) of the creation data: `"INEI 1999"`, `"INEI 2020"`, `"INEI 2022"`, `"JNE 2021"`, `"Congreso 2025"`}
#'   \item{note}{Warnings about the data (possible errors in the source)}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the unit
#'     existed at the census date, 0 if it was created afterwards. See Details.}
#' }
#' @details
#' **Census presence.** A unit is coded as present in a census when it had
#' been created before the census date (12/07/1981, 11/07/1993, 21/10/2007,
#' 22/10/2017). Units not listed as created between 1981 and 2025 in the
#' sources existed before the 1981 Census. The coding reproduces exactly the
#' national counts of provinces and districts published by INEI (2020) for each
#' census, and the national and department counts at 31/12/2021 published by
#' INEI (2022). Presence refers to the unit as identified in 2025: units that were
#' split, merged or moved between departments keep their 2025 identity, and
#' units abolished before 2025 are not included. See
#' `vignette("construction", package = "ubigeocensos")`.
#' @source INEI, list of UBIGEO codes of the 2025 Census; INEI (1999), see
#'   [inei1999_districts]; INEI (2020) and INEI (2022), see [division_counts];
#'   JNE (2021) and Congreso de la República (2025), see
#'   [districts_created_2020_2025].
"provinces"

#' Districts of Peru (Census 2025)
#'
#' Districts in the 2025 Census, identified by their INEI UBIGEO code, with
#' their creation date, legal instrument of creation and presence in each census.
#'
#' @format A tibble with 1,892 rows and 15 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI, Census 2025), 6-character string}
#'   \item{department}{Name of the department}
#'   \item{province}{Name of the province}
#'   \item{district}{Name of the district}
#'   \item{created_date}{Date of creation (`Date`). Law date for INEI 1999;
#'     publication date for INEI 2020 provinces; date listed by JNE 2021 /
#'     Congreso 2025. `NA` when only the year is known.}
#'   \item{created_year}{Year of creation}
#'   \item{legal_instrument}{Type and number of the legal instrument of creation (e.g. `"LEY 15246"`)}
#'   \item{independence_era}{`TRUE` if the source dates the unit to the Independence era (no instrument of creation)}
#'   \item{creation_source}{Source(s) of the creation data: `"INEI 1999"`, `"INEI 2020"`, `"INEI 2022"`, `"JNE 2021"`, `"Congreso 2025"`}
#'   \item{note}{Warnings about the data (possible errors in the source)}
#'   \item{census_1981,census_1993,census_2007,census_2017,census_2025}{1 if the unit
#'     existed at the census date, 0 if it was created afterwards. See Details.}
#' }
#' @details
#' **Census presence.** A unit is coded as present in a census when it had
#' been created before the census date (12/07/1981, 11/07/1993, 21/10/2007,
#' 22/10/2017). Units not listed as created between 1981 and 2025 in the
#' sources existed before the 1981 Census. The coding reproduces exactly the
#' national counts of provinces and districts published by INEI (2020) for each
#' census, and the national and department counts at 31/12/2021 published by
#' INEI (2022). Presence refers to the unit as identified in 2025: units that were
#' split, merged or moved between departments keep their 2025 identity, and
#' units abolished before 2025 are not included. See
#' `vignette("construction", package = "ubigeocensos")`.
#' @source INEI, list of UBIGEO codes of the 2025 Census; INEI (1999), see
#'   [inei1999_districts]; INEI (2020) and INEI (2022), see [division_counts];
#'   JNE (2021) and Congreso de la República (2025), see
#'   [districts_created_2020_2025].
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

#' Number of departments, provinces and districts at each census, INEI 2020 and 2022
#'
#' Cuadros 1 and 2 of the "División política y administrativa" chapter of INEI
#' (2020), updated to 31/12/2021 in Anexo 2 of INEI (2022): "Perú: División
#' político administrativa, según fecha censal del período 1940-2017 y
#' actualizada al 31 de diciembre de 2021" (national rows) and the same table
#' by department. Department rows follow the demarcation in force at the end
#' of the reference year (2019 in INEI 2020, 2021 in INEI 2022).
#'
#' @format A tibble with 235 rows and 9 variables:
#' \describe{
#'   \item{level}{`"national"` or `"department"`}
#'   \item{inei}{UBIGEO (2025) of the department; `NA` for national rows}
#'   \item{department}{Name as published}
#'   \item{census_year}{Census year; `NA` for the 31/12/2019 and 31/12/2021 rows}
#'   \item{date}{Census date, 2019-12-31 or 2021-12-31}
#'   \item{n_departments}{Number of departments (national rows; excludes Callao)}
#'   \item{n_provinces}{Number of provinces (includes Callao)}
#'   \item{n_districts}{Number of districts}
#'   \item{source}{`"INEI 2020; INEI 2022"` when both editions report the
#'     figure (they agree in every case), `"INEI 2022"` otherwise}
#' }
#' @details The national and department tables are not fully consistent: for
#'   2005 the national table reports 1,811 districts and the department table
#'   sums to 1,831; for 2007, 1,833 and 1,834. The INEI 2022 figures were
#'   transcribed from page images and checked against the figures parsed from
#'   the INEI 2020 PDF.
#' @source
#'   Instituto Nacional de Estadística e Informática (2020). *Perú:
#'   Proyecciones de Población por Departamento, Provincia y Distrito, 2018 -
#'   2020*. Boletín Especial Nº 26. Lima: INEI. Chapter 2, "División política y
#'   administrativa al 31 de diciembre del 2019".
#'   <https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1715/libro.pdf>
#'
#'   Instituto Nacional de Estadística e Informática (2022). *Perú:
#'   Proyecciones de Población Total según Departamento, Provincia y Distrito,
#'   2018 - 2022*. Boletín Especial Nº 27. Lima: INEI. Anexo 2, "División
#'   política y administrativa al 31 de diciembre de 2021".
#'   <https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1860/libro.pdf>
"division_counts"

#' Provinces created 1981-2021, INEI 2020 and 2022
#'
#' Cuadro "Perú: Relación de provincias creadas desde el 12 de julio de 1981 al
#' 31 de diciembre de 2021" (INEI 2022), which lists the same 43 provinces as
#' the 2019 edition (INEI 2020): no provinces were created in 2020-2021.
#'
#' @format A tibble with 43 rows and 7 variables:
#' \describe{
#'   \item{inei}{UBIGEO (INEI) of the province}
#'   \item{department,province}{Names as published}
#'   \item{law_number}{Number of the law of creation, as published}
#'   \item{published}{Publication date of the law}
#'   \item{note}{Footnotes and warnings}
#'   \item{source}{Sources reporting the row}
#' }
#' @source INEI (2020) and INEI (2022), see [division_counts].
"inei_provinces_created"

#' Districts created 1981-2021, INEI 2020 and 2022
#'
#' Cuadro "Perú: Relación de distritos creados y procedencia territorial,
#' según ley de creación, 1981 - 2021" of INEI (2022), matched to the 2025
#' UBIGEO. Rows 1-194 are also in the 2019 edition (INEI 2020), which numbered
#' them up to 203 because it skipped 161-169; rows 195-210 are the 16
#' districts created in 2020-2021.
#'
#' @format A tibble with 210 rows and 9 variables:
#' \describe{
#'   \item{n}{Row number in INEI (2022)}
#'   \item{n_2020}{Row number in INEI (2020); `NA` for rows 195-210}
#'   \item{inei}{UBIGEO (2025) of the created district}
#'   \item{year}{Year of creation (year heading in the source)}
#'   \item{law_number}{Number of the law of creation}
#'   \item{district,province,department}{Names as published (province and
#'     department at the time of creation): rows 1-194 as parsed from INEI
#'     (2020), rows 195-210 as transcribed from INEI (2022)}
#'   \item{source}{Sources reporting the row}
#' }
#' @source INEI (2020) and INEI (2022), see [division_counts].
"inei_districts_created"

#' Territorial origin of districts created 1981-2021, INEI 2020 and 2022
#'
#' The "procedencia territorial" columns of [inei_districts_created]: the
#' district(s) from which each new district was carved. One row per origin.
#'
#' @format A tibble with one row per created district and origin, 6 variables:
#' \describe{
#'   \item{n}{Row number in INEI (2022) (links to [inei_districts_created])}
#'   \item{inei}{UBIGEO (2025) of the created district}
#'   \item{origin_inei}{UBIGEO (2025) of the origin district; `NA` for two
#'     origins that are inconsistent in the source ("Acobamba", Chincheros; and
#'     "Camilaca", Azángaro)}
#'   \item{origin_district,origin_province,origin_department}{Names as published}
#' }
#' @source INEI (2020) and INEI (2022), see [division_counts].
"inei_district_origins"

#' Districts created 2020-2025
#'
#' The 18 districts in the 2025 Census frame that were created after
#' 31/12/2019 (1,892 - 1,874), with the exact date of their law. The 16
#' created in 2020-2021 are also in [inei_districts_created] (year and law
#' only); the build checks that both sources agree on the law and year.
#'
#' @format A tibble with 18 rows and 7 variables:
#' \describe{
#'   \item{inei}{UBIGEO (2025)}
#'   \item{department,province,district}{Names}
#'   \item{law_number}{Number of the law of creation}
#'   \item{date}{Date of the law as listed in the source}
#'   \item{source}{`"JNE 2021"` or `"Congreso 2025"`}
#' }
#' @source Jurado Nacional de Elecciones (2021). Resolución N.° 0913-2021-JNE,
#'   22 de noviembre de 2021, considerando 1.10.
#'   <https://portal.jne.gob.pe/portal_documentos/files/72803f45-044d-4c92-841b-6b2dbe8efc0a.pdf>
#'
#'   Congreso de la República (2025). *Leyes de creación de distritos*. Área de
#'   Estadística Parlamentaria. <https://www.congreso.gob.pe/Docs/DGP/GestionInformacionEstadistica/files/publicaciones-25/leyes-declarativas-creaci%C3%93n-distritos.pdf>
"districts_created_2020_2025"
