# Step 4: political-administrative division at 31/12/2021 (INEI 2022)
#
# Source: Instituto Nacional de Estadística e Informática (2022). Perú:
#   Proyecciones de Población Total según Departamento, Provincia y Distrito,
#   2018-2022. Boletín Especial Nº 27. Lima: INEI, abril 2022. Anexo 2,
#   "División política y administrativa al 31 de diciembre de 2021".
#   https://www.inei.gob.pe/media/MenuRecursivo/publicaciones_digitales/Est/Lib1860/libro.pdf
#
# Anexo 2 updates the tables of INEI (2020) to 31/12/2021. Its tables were
# transcribed from page images (data-raw/inei2022_be27/images/):
#   cuadro1_national.csv              Cuadro 1 (national counts, incl. 31/12/2021)
#   cuadro2_department.csv            Cuadro 2 (counts by department, incl. 2021)
#   cuadro4_districts_2020_2021.csv   Cuadro 4, rows 195-210 (districts created
#                                     2020-2021 and their territorial origin)
# Cuadro 3 (provinces created since 12/07/1981) lists the same 43 provinces as
# INEI (2020): no provinces were created in 2020-2021. Rows 1-194 of Cuadro 4
# are the 194 rows of INEI (2020), renumbered consecutively (INEI 2020 skipped
# numbers 161-169).
#
# Every transcribed figure that INEI (2020) also reports is checked against the
# values parsed from the INEI (2020) PDF; the script stops if any differs.
#
# Output (in the calling environment, replacing the INEI 2020 objects):
#   division_counts, inei_provinces_created, inei_districts_created,
#   inei_district_origins

be27 <- "data-raw/inei2022_be27"

# ---- Cuadro 1 and 2: counts ----------------------------------------------
c1 <- utils::read.csv(file.path(be27, "cuadro1_national.csv"))
national27 <- data.frame(
  level = "national", inei = NA_character_, department = "PERU",
  date = as.Date(c1$date), n_departments = c1$n_departments,
  n_provinces = c1$n_provinces, n_districts = c1$n_districts)

c2 <- utils::read.csv(file.path(be27, "cuadro2_department.csv"), encoding = "UTF-8",
                      check.names = FALSE)
yrs27 <- c(names(census_dates), "2021")
dates27 <- as.Date(c(census_dates, "2021" = "2021-12-31"))
by_dept27 <- do.call(rbind, lapply(seq_len(nrow(c2)), function(k) {
  data.frame(level = "department", inei = dept_code(c2$department[k]),
             department = c2$department[k], date = dates27,
             n_departments = NA_integer_,
             n_provinces = unlist(c2[k, paste0("p", yrs27)]),
             n_districts = unlist(c2[k, paste0("d", yrs27)]))
}))
rownames(by_dept27) <- NULL
stopifnot(!anyNA(by_dept27$inei), length(unique(by_dept27$inei)) == 25)
counts27 <- rbind(national27, by_dept27)

# Check the transcription against INEI (2020)
both <- merge(counts27, division_counts, by = c("level", "inei", "date"),
              suffixes = c("_2022", "_2020"))
stopifnot(nrow(both) == nrow(division_counts))
neq <- function(a, b) (is.na(a) != is.na(b)) | (!is.na(a) & !is.na(b) & a != b)
diff <- with(both, neq(n_departments_2022, n_departments_2020) |
               neq(n_provinces_2022, n_provinces_2020) |
               neq(n_districts_2022, n_districts_2020))
if (any(diff)) {
  print(both[diff, ])
  stop("INEI 2022 transcription differs from INEI 2020 for the rows above.")
}
# Sums by department must equal the published totals for 2021 (1,890 districts)
stopifnot(sum(by_dept27$n_districts[by_dept27$date == as.Date("2021-12-31")]) == 1890,
          sum(by_dept27$n_provinces[by_dept27$date == as.Date("2021-12-31")]) == 196)

division_counts <- counts27
division_counts$census_year <- as.integer(format(division_counts$date, "%Y"))
division_counts$census_year[format(division_counts$date, "%m-%d") == "12-31"] <- NA
division_counts$source <- ifelse(division_counts$date > as.Date("2019-12-31") |
                                   (division_counts$level == "department" &
                                      division_counts$date == as.Date("2019-12-31")),
                                 "INEI 2022", "INEI 2020; INEI 2022")
division_counts <- tibble::as_tibble(division_counts[, c(
  "level", "inei", "department", "census_year", "date",
  "n_departments", "n_provinces", "n_districts", "source")])

# ---- Cuadro 3: provinces (unchanged since INEI 2020) ----------------------
inei_provinces_created <- inei2020_provinces_created
inei_provinces_created$source <- "INEI 2020; INEI 2022"

# ---- Cuadro 4: districts created 1981-2021 ---------------------------------
district_equivalences_2020 <- c(district_equivalences_2020,
  "08|KIMPIRUSHIATO" = "KUMPIRUSHIATO",
  "09|TINTAY PUNCO" = "TINTAY PUNCU")

renumber <- function(n) ifelse(n <= 160, n, n - 9L)   # INEI 2020 skipped 161-169

old <- as.data.frame(inei2020_districts_created)
old$n_2020 <- old$n
old$n <- renumber(old$n)
old$source <- "INEI 2020; INEI 2022"

c4 <- utils::read.csv(file.path(be27, "cuadro4_districts_2020_2021.csv"),
                      colClasses = "character", encoding = "UTF-8")
c4$n <- as.integer(c4$n)
# Blank province/department in an origin line repeat the line above (row 195)
for (k in seq_len(nrow(c4))[-1]) {
  if (c4$origin_province[k] == "" && c4$n[k] == c4$n[k - 1]) {
    c4$origin_province[k] <- c4$origin_province[k - 1]
    c4$origin_department[k] <- c4$origin_department[k - 1]
  }
}
new <- unique(c4[, c("n", "year", "law_number", "district", "province", "department")])
new$year <- as.integer(new$year)
new$inei <- match_district(new$department, new$province, new$district)
new$n_2020 <- NA_integer_
new$source <- "INEI 2022"
stopifnot(!anyNA(new$inei), !any(new$inei %in% old$inei))

cols <- c("n", "n_2020", "inei", "year", "law_number", "district", "province",
          "department", "source")
inei_districts_created <- tibble::as_tibble(rbind(old[, cols], new[, cols]))
stopifnot(identical(inei_districts_created$n, seq_len(210L)),
          !anyDuplicated(inei_districts_created$inei))

new_orig <- c4[, c("n", "origin_district", "origin_province", "origin_department")]
new_orig$origin_inei <- match_district(new_orig$origin_department, new_orig$origin_province,
                                       new_orig$origin_district)
new_orig$inei <- new$inei[match(new_orig$n, new$n)]
old_orig <- as.data.frame(inei2020_district_origins)
old_orig$n <- renumber(old_orig$n)
ocols <- c("n", "inei", "origin_inei", "origin_district", "origin_province", "origin_department")
inei_district_origins <- tibble::as_tibble(rbind(old_orig[, ocols], new_orig[, ocols]))

message("INEI 2022: ", nrow(inei_districts_created), " districts created 1981-2021 (",
        nrow(new), " new since INEI 2020); ",
        sum(is.na(inei_district_origins$origin_inei)), " origin districts unmatched")
