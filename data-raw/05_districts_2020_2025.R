# Step 5: dates of districts created after 31/12/2019
#
# The 2025 frame has 1,892 districts and INEI (2020) reports 1,874 at
# 31/12/2019, so 18 districts were created in 2020-2025. INEI (2022) lists the
# 16 created in 2020-2021 with year and law only; the exact dates of those 16,
# and the 2 districts created after 2021, are taken from:
#
#   Jurado Nacional de Elecciones (2021). Resolución N.° 0913-2021-JNE,
#     22 de noviembre de 2021, considerando 1.10 (16 districts created
#     2020-2021, "posterior" to the 2017 Census).
#     https://portal.jne.gob.pe/portal_documentos/files/72803f45-044d-4c92-841b-6b2dbe8efc0a.pdf
#   Congreso de la República (2025). Leyes de creación de distritos
#     (Área de Estadística Parlamentaria): Ley 31644 (Alto Trujillo,
#     15/12/2022) and Ley 32403 (Santa Rosa de Loreto, 03/07/2025).
#     https://www.congreso.gob.pe/Docs/DGP/GestionInformacionEstadistica/files/publicaciones-25/leyes-declarativas-creaciÓn-distritos.pdf
#
# Input : data-raw/post2019/districts_created_2020_2025.csv (transcribed)
# Output: `districts_created_2020_2025` in the calling environment

districts_created_2020_2025 <- utils::read.csv(
  "data-raw/post2019/districts_created_2020_2025.csv",
  colClasses = "character", encoding = "UTF-8")

d25 <- units2025[units2025$level == "district", ]
p25 <- units2025[units2025$level == "province", ]
key25 <- paste(normalize_name(p25$name[match(d25$parent, p25$inei)]), normalize_name(d25$name), sep = "|")
districts_created_2020_2025$inei <- d25$inei[match(
  paste(districts_created_2020_2025$province, districts_created_2020_2025$district, sep = "|"), key25)]
stopifnot(!anyNA(districts_created_2020_2025$inei),
          !any(districts_created_2020_2025$inei %in% inei2020_districts_created$inei))

# Cross-check with INEI (2022): same districts and laws for 2020-2021
x <- merge(districts_created_2020_2025, inei_districts_created, by = "inei")
stopifnot(nrow(x) == 16, all(x$law_number.x == x$law_number.y),
          all(as.integer(substr(x$date, 1, 4)) == x$year))
stopifnot(setequal(x$inei, inei_districts_created$inei[inei_districts_created$year >= 2020]))
districts_created_2020_2025$date <- as.Date(districts_created_2020_2025$date)
districts_created_2020_2025 <- tibble::as_tibble(districts_created_2020_2025[, c(
  "inei", "department", "province", "district", "law_number", "date", "source")])
