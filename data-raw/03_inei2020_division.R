# Step 3: political-administrative division at census dates (INEI 2020)
#
# Source: Instituto Nacional de Estadística e Informática (2020). Perú:
#   Proyecciones de Población por Departamento, Provincia y Distrito, 2018-2020.
#   Boletín Especial Nº 26. Lima: INEI. Chapter 2, "División política y
#   administrativa al 31 de diciembre del 2019".
#   https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1715/libro.pdf
#
# Input : data-raw/inei2020_be26/cap02_division_politica_2019.pdf
# Output (in the calling environment):
#   division_counts            number of departments/provinces/districts per census
#   inei2020_provinces_created provinces created 12/07/1981 - 31/12/2019
#   inei2020_districts_created districts created 1981 - 2019
#   inei2020_district_origins  territorial origin of each created district

pdf_file <- "data-raw/inei2020_be26/cap02_division_politica_2019.pdf"
pages_txt <- pdftools::pdf_text(pdf_file)
pages_dat <- pdftools::pdf_data(pdf_file)

census_dates <- c("1940" = "1940-06-09", "1961" = "1961-07-02", "1972" = "1972-06-04",
                  "1981" = "1981-07-12", "1993" = "1993-07-11", "2005" = "2005-08-03",
                  "2007" = "2007-10-21", "2017" = "2017-10-22")

# Normalised names used for matching with the 2025 frame. Expands the
# abbreviations used in the INEI tables (Crnel., Mcal., Stgo., ...).
norm_inei2020 <- function(x) {
  x <- normalize_name(x)
  x <- gsub("\\bCRNEL\\.\\s*", "CORONEL ", x)
  x <- gsub("\\bMCAL\\.?\\s*R\\.\\s*CASTILLA", "MARISCAL RAMON CASTILLA", x)
  x <- gsub("\\bMCAL\\.\\s*", "MARISCAL ", x)
  x <- gsub("\\bSTGO\\.\\s*(DE\\s*)?", "SANTIAGO DE ", x)
  x <- gsub("\\bSTA\\.\\s*", "SANTA ", x)
  x <- gsub("\\bM\\.A\\.\\s*", "MANUEL ANTONIO ", x)
  x <- gsub("^PROV\\. CONST\\. DEL CALLAO$", "CALLAO", x)
  x <- gsub("[-]", " ", x)
  trimws(gsub("\\s+", " ", x))
}

dept_code <- function(name) {
  d <- units2025[units2025$level == "department", ]
  d$inei[match(norm_inei2020(name), normalize_name(d$name))]
}

# ---- Table 1 and 2: counts by census -------------------------------------
p3 <- strsplit(pages_txt[3], "\n")[[1]]

nat <- regmatches(p3, regexec(
  "^\\s*(\\d{2}) ([A-Z]+) (\\d{4})\\s+(\\d+)\\s+(\\d+)\\s+([0-9][0-9 ]*[0-9])\\s*$", p3))
nat <- do.call(rbind, nat[lengths(nat) > 0])
meses <- c(ENERO = 1, FEBRERO = 2, MARZO = 3, ABRIL = 4, MAYO = 5, JUNIO = 6, JULIO = 7,
           AGOSTO = 8, SETIEMBRE = 9, SEPTIEMBRE = 9, OCTUBRE = 10, NOVIEMBRE = 11, DICIEMBRE = 12)
national <- data.frame(
  level = "national", inei = NA_character_, department = "PERU",
  date = as.Date(sprintf("%s-%02d-%s", nat[, 4], meses[nat[, 3]], nat[, 2])),
  n_departments = as.integer(nat[, 5]),
  n_provinces = as.integer(nat[, 6]),
  n_districts = as.integer(gsub(" ", "", nat[, 7]))
)

years <- names(census_dates)
dep_lines <- p3[grepl("^[A-ZÁÉÍÓÚ][A-Za-zÁÉÍÓÚáéíóúñ. ]+?\\s{2,}[-\\d]", p3, perl = TRUE) &
                  !grepl("^\\s*(Total|Departamento)", p3)]
by_dept <- do.call(rbind, lapply(dep_lines, function(l) {
  name <- trimws(sub("\\s{2,}.*$", "", l))
  vals <- strsplit(trimws(sub("^.*?\\s{2,}", "", l)), "\\s+")[[1]]
  stopifnot(length(vals) == 2 * length(years))
  vals <- suppressWarnings(as.integer(ifelse(vals == "-", NA, vals)))
  data.frame(level = "department", inei = dept_code(name), department = name,
             date = as.Date(census_dates),
             n_departments = NA_integer_,
             n_provinces = vals[c(TRUE, FALSE)],
             n_districts = vals[c(FALSE, TRUE)])
}))
stopifnot(!anyNA(by_dept$inei), length(unique(by_dept$inei)) == 25)
division_counts <- rbind(national, by_dept)
division_counts$census_year <- as.integer(format(division_counts$date, "%Y"))
division_counts$census_year[format(division_counts$date, "%Y-%m-%d") == "2019-12-31"] <- NA
division_counts <- tibble::as_tibble(division_counts[, c(
  "level", "inei", "department", "census_year", "date",
  "n_departments", "n_provinces", "n_districts")])

# ---- Table 3: provinces created since 12/07/1981 ---------------------------
mes3 <- c(ENE = 1, FEB = 2, MAR = 3, ABR = 4, MAY = 5, JUN = 6, JUL = 7,
          AGO = 8, SET = 9, OCT = 10, NOV = 11, DIC = 12)
pl <- unlist(strsplit(pages_txt[4:5], "\n"))
pm <- regmatches(pl, regexec(
  "^\\s*(\\d{2}) ([A-Z]{3}) (\\d{2})\\s+(\\d+)\\s+(\\d{4})\\s+(.+?)\\s{2,}(.+?)\\s*$", pl))
pm <- do.call(rbind, pm[lengths(pm) > 0])
yy <- as.integer(pm[, 4]); yy <- ifelse(yy > 50, 1900 + yy, 2000 + yy)
inei2020_provinces_created <- data.frame(
  inei = paste0(pm[, 6], "00"),
  department = pm[, 7],
  province = trimws(sub("\\s*\\d/$", "", pm[, 8])),
  law_number = pm[, 5],
  published = as.Date(sprintf("%d-%02d-%s", yy, mes3[pm[, 3]], pm[, 2])),
  note = NA_character_
)
inei2020_provinces_created$note[inei2020_provinces_created$inei == "020700"] <-
  "Renamed Carlos Fermín Fitzcarrald by Law 24893 (20/10/1988), per source footnote."
inei2020_provinces_created$note[inei2020_provinces_created$law_number == "228593"] <-
  "Law number as published (228593); the district table gives Law 28593 for Datem del Marañón."

# ---- Table 4: districts created 1981-2019 (word coordinates) ---------------
# Columns are right-aligned; each text chunk is assigned to the nearest right edge.
edges <- c(num = 81, law = 108, dist = 213, prov = 276, dept = 331,
           odist = 399, oprov = 465, odept = 525, year = 306)
chunks <- do.call(rbind, lapply(6:12, function(pg) {
  w <- pages_dat[[pg]]
  w <- w[w$y > 125 & w$y < 775, ]
  w$x1 <- w$x + w$width
  w <- w[order(w$y, w$x), ]
  do.call(rbind, lapply(unique(w$y), function(yy) {
    r <- w[w$y == yy, ]
    id <- cumsum(c(TRUE, r$x[-1] - r$x1[-nrow(r)] > 4))
    do.call(rbind, lapply(unique(id), function(k) {
      x1 <- max(r$x1[id == k])
      data.frame(key = paste(pg, yy), x1 = x1,
                 col = names(edges)[which.min(abs(edges - x1))],
                 txt = paste(r$text[id == k], collapse = " "))
    }))
  }))
}))
chunks <- chunks[!grepl("^(Continúa|Conclusión|Fuente)", chunks$txt), ]

created <- list(); origins <- list(); year <- NA_integer_; cur <- NA_integer_
for (k in unique(chunks$key)) {
  r <- chunks[chunks$key == k, ]
  v <- setNames(r$txt, r$col)
  g <- function(n) if (n %in% names(v)) v[[n]] else NA_character_
  if (nrow(r) == 1 && r$col == "year" && grepl("^\\d{4}$", r$txt)) {
    year <- as.integer(r$txt); next
  }
  if ("num" %in% names(v)) {
    cur <- as.integer(v[["num"]])
    created[[length(created) + 1]] <- data.frame(
      n = cur, year = year, law_number = g("law"),
      district = g("dist"), province = g("prov"), department = g("dept"))
  }
  if (any(c("odist", "oprov", "odept") %in% names(v)))
    origins[[length(origins) + 1]] <- data.frame(
      n = cur, origin_district = g("odist"), origin_province = g("oprov"),
      origin_department = g("odept"))
}
created <- do.call(rbind, created)
origins <- do.call(rbind, origins)

# Manual fixes for cells that wrap over two lines or merge two columns
fix <- created$n == 53
created$district[fix] <- "Sara Sara"
created$province[fix] <- "Paucar del Sara Sara"
fix <- created$n == 174
created$province[fix] <- created$department[fix] <- "Prov. Const. del Callao"
origins <- origins[!(origins$n == 173 & is.na(origins$origin_district)), ]
origins <- origins[!(origins$n == 174 & (is.na(origins$origin_district) | is.na(origins$origin_department))), ]
origins <- rbind(origins, data.frame(
  n = 174, origin_district = "Ventanilla", origin_province = "Prov. Const. del Callao",
  origin_department = "Prov. Const. del Callao"))
origins$origin_district[origins$n == 11 & origins$origin_district %in% "San Marcos"] <-
  "San Marcos (Pedro Gálvez)"
origins <- origins[!(origins$n == 11 & origins$origin_district %in% "Pedro Gálvez"), ]
origins <- origins[!(origins$n == 150 & (origins$origin_district %in% c("Limbani (solo cede", "territorio)") |
                                         is.na(origins$origin_district))), ]
origins <- rbind(origins, data.frame(
  n = 150, origin_district = "Limbani (solo cede territorio)",
  origin_province = "Sandia", origin_department = "Puno"))
origins <- origins[order(origins$n), ]
stopifnot(!anyNA(created), !anyNA(origins), nrow(created) == 194)

# ---- Matching to the 2025 frame --------------------------------------------
# District names in the 1981-2019 list that differ from the 2025 list
# ("dept|name in source" = "name in 2025")
district_equivalences_2020 <- c(
  "25|CAMPO VERDE" = "CAMPOVERDE",
  "25|CALLARIA" = "CALLERIA",
  "25|ANTONIO RAYMONDI" = "RAIMONDI",
  "06|SAN MARCOS" = "PEDRO GALVEZ",            # capital district of San Marcos province
  "10|CODO DE POZUZO" = "CODO DEL POZUZO",
  "10|QUISQUI" = "QUISQUI (KICHKI)",
  "21|CUTARAPI" = "CUTURAPI",
  "21|CAPASO" = "CAPAZO",
  "21|CONINA" = "CONIMA",
  "21|YANAHUARA" = "YANAHUAYA",
  "21|SAN PEDRO DE PUTINA PUNCU" = "SAN PEDRO DE PUTINA PUNCO",
  "08|QUIMBIRI" = "KIMBIRI",
  "11|NAZCA" = "NASCA"
)
# Origin districts left unmatched on purpose (inconsistent in the source):
#   n = 117 "Acobamba" (Chincheros, Apurímac): no such district in Chincheros.
#   n = 203 "Camilaca" (Azángaro, Puno): Camilaca is a district of Candarave, Tacna.

match_district <- function(dept, prov, dist) {
  d25 <- units2025[units2025$level == "district", ]
  p25 <- units2025[units2025$level == "province", ]
  d25$dn <- norm_inei2020(d25$name)
  d25$pn <- norm_inei2020(p25$name[match(d25$parent, p25$inei)])
  d25$dep <- substr(d25$inei, 1, 2)
  dc <- substr(dept_code(dept), 1, 2)
  dn <- trimws(sub("\\(ANTES .*\\)$", "", norm_inei2020(dist)))
  key <- paste(dc, dn, sep = "|")
  dn <- ifelse(key %in% names(district_equivalences_2020), district_equivalences_2020[key], dn)
  pn <- norm_inei2020(prov)
  vapply(seq_along(dn), function(i) {
    cand <- d25[d25$dep %in% dc[i] & d25$dn == dn[i], ]
    if (nrow(cand) > 1) cand <- cand[cand$pn == pn[i], ]
    if (nrow(cand) == 1) cand$inei else NA_character_
  }, character(1))
}

created$inei <- match_district(created$department, created$province, created$district)

inei2020_districts_created <- tibble::as_tibble(created[, c(
  "n", "inei", "year", "law_number", "district", "province", "department")])

# One origin row gives "Huaylas" as department; fall back to the created district's department
odept <- ifelse(is.na(dept_code(origins$origin_department)),
                created$department[match(origins$n, created$n)], origins$origin_department)
origins$origin_inei <- match_district(odept, origins$origin_province,
                                      sub(" \\(.*\\)$", "", origins$origin_district))
origins$inei <- created$inei[match(origins$n, created$n)]
inei2020_district_origins <- tibble::as_tibble(origins[, c(
  "n", "inei", "origin_inei", "origin_district", "origin_province", "origin_department")])

message("INEI 2020: ", nrow(inei2020_provinces_created), " provinces and ",
        nrow(inei2020_districts_created), " districts created; ",
        sum(is.na(inei2020_districts_created$inei)), " created districts and ",
        sum(is.na(inei2020_district_origins$origin_inei)), " origin districts unmatched")
