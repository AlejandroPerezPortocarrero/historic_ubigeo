# Builds every dataset in the package.
# Run from the package root:  source("data-raw/make_datasets.R")

source("data-raw/00_helpers.R")
source("data-raw/01_units_2025.R")          # frame: units in the 2025 Census
source("data-raw/02_inei1999_creation.R")   # INEI (1999): creation of districts (Lima so far)
source("data-raw/03_inei2020_division.R")   # INEI (2020): division at census dates, 1981-2019 creations
source("data-raw/04_inei2022_division.R")   # INEI (2022): update to 31/12/2021, 1981-2021 creations
source("data-raw/05_districts_2020_2025.R") # JNE (2021), Congreso (2025): dates of 2020-2025 creations

census_cut <- as.Date(c("1981" = "1981-07-12", "1993" = "1993-07-11",
                        "2007" = "2007-10-21", "2017" = "2017-10-22"))

# ---- Master table (all levels) -------------------------------------------
master <- units2025
master$created_date     <- as.Date(NA)
master$created_year     <- NA_integer_
master$legal_instrument <- NA_character_
master$independence_era <- NA
master$creation_source  <- NA_character_
master$note             <- NA_character_

add_source <- function(old, new) ifelse(is.na(old), new, paste(old, new, sep = "; "))

# (a) INEI 1999: exact date and instrument of districts existing in 1999
i <- match(master$inei, inei1999_districts$inei); h <- !is.na(i)
instr99 <- trimws(paste(ifelse(is.na(inei1999_districts$instrument_type), "", inei1999_districts$instrument_type),
                        ifelse(is.na(inei1999_districts$instrument_number), "", inei1999_districts$instrument_number)))
instr99[instr99 == ""] <- NA
master$created_date[h]     <- as.Date(inei1999_districts$created_date[i[h]])
master$legal_instrument[h] <- instr99[i[h]]
master$independence_era[h] <- inei1999_districts$independence_era[i[h]]
master$creation_source[h]  <- "INEI 1999"
master$note[h]             <- inei1999_districts$note[i[h]]

# (b) INEI 2020/2022: provinces created 1981-2021 (publication date of the law)
i <- match(master$inei, inei_provinces_created$inei); h <- !is.na(i)
master$created_date[h]     <- inei_provinces_created$published[i[h]]
master$legal_instrument[h] <- paste("LEY", inei_provinces_created$law_number[i[h]])
master$independence_era[h] <- FALSE
master$creation_source[h]  <- inei_provinces_created$source[i[h]]
master$note[h]             <- inei_provinces_created$note[i[h]]

# (c) INEI 2020/2022: districts created 1981-2021 (year and law; date only if INEI 1999 has it)
i <- match(master$inei, inei_districts_created$inei); h <- !is.na(i)
law20 <- paste("LEY", inei_districts_created$law_number[i[h]])
clash <- !is.na(master$legal_instrument[h]) & master$legal_instrument[h] != law20
if (any(clash)) warning("INEI 1999 and INEI 2020 disagree on the law of: ",
                        paste(master$inei[h][clash], collapse = ", "))
master$created_year[h]     <- inei_districts_created$year[i[h]]
master$legal_instrument[h] <- ifelse(is.na(master$legal_instrument[h]), law20, master$legal_instrument[h])
master$independence_era[h] <- FALSE
master$creation_source[h]  <- add_source(master$creation_source[h], inei_districts_created$source[i[h]])

# (d) JNE 2021 / Congreso 2025: exact dates of districts created 2020-2025
i <- match(master$inei, districts_created_2020_2025$inei); h <- !is.na(i)
master$created_date[h]     <- districts_created_2020_2025$date[i[h]]
master$legal_instrument[h] <- paste("LEY", districts_created_2020_2025$law_number[i[h]])
master$independence_era[h] <- FALSE
master$creation_source[h]  <- add_source(master$creation_source[h], districts_created_2020_2025$source[i[h]])

master$created_year <- ifelse(is.na(master$created_date), master$created_year,
                              as.integer(format(master$created_date, "%Y")))

# ---- Presence in each census ---------------------------------------------
# A unit is present in a census if it had been created before the census date.
# Units not created 1981-2025 according to the sources existed before the 1981
# Census. Districts created in a census year without exact date (1981, 1993)
# were created after that census: this reproduces INEI's national counts
# (checked below).
created_after <- function(cut) {
  y <- as.integer(format(cut, "%Y"))
  ifelse(!is.na(master$created_date), master$created_date >= cut,
         ifelse(!is.na(master$created_year), master$created_year >= y, FALSE))
}
recent <- master$inei %in% c(inei_provinces_created$inei, inei_districts_created$inei,
                             districts_created_2020_2025$inei)
for (y in names(census_cut)) {
  master[[paste0("census_", y)]] <- ifelse(recent & created_after(census_cut[[y]]), 0L, 1L)
}
master$census_2025 <- 1L

# Check against INEI (2020), table "División político administrativa según fecha censal"
nat <- division_counts[division_counts$level == "national" & !is.na(division_counts$census_year), ]
for (y in names(census_cut)) {
  got <- c(sum(master$level == "province" & master[[paste0("census_", y)]] == 1),
           sum(master$level == "district" & master[[paste0("census_", y)]] == 1))
  want <- unlist(nat[nat$census_year == as.integer(y), c("n_provinces", "n_districts")])
  if (!all(got == want)) stop("Census ", y, ": got ", paste(got, collapse = "/"),
                              ", INEI reports ", paste(want, collapse = "/"))
}
# ...and against the division at 31/12/2021 (INEI 2022), nationally and by department
in2021 <- ifelse(recent & created_after(as.Date("2022-01-01")), 0L, 1L)
d21 <- division_counts[!is.na(division_counts$date) & division_counts$date == as.Date("2021-12-31"), ]
for (k in seq_len(nrow(d21))) {
  sel <- if (is.na(d21$inei[k])) TRUE else substr(master$inei, 1, 2) == substr(d21$inei[k], 1, 2)
  got <- c(sum(sel & master$level == "province" & in2021 == 1),
           sum(sel & master$level == "district" & in2021 == 1))
  want <- c(d21$n_provinces[k], d21$n_districts[k])
  if (!all(got == want)) stop("31/12/2021, ", d21$department[k], ": got ",
                              paste(got, collapse = "/"), ", INEI reports ", paste(want, collapse = "/"))
}
message("Census presence reproduces INEI national counts for 1981, 1993, 2007 and 2017, ",
        "and national and department counts at 31/12/2021.")

# ---- Final tables ---------------------------------------------------------
dept_name <- setNames(master$name, master$inei)
master$department <- dept_name[paste0(substr(master$inei, 1, 2), "0000")]
master$province   <- ifelse(master$level == "department", NA,
                            dept_name[paste0(substr(master$inei, 1, 4), "00")])

common <- c("created_date", "created_year", "legal_instrument", "independence_era",
            "creation_source", "note", paste0("census_", census_years))

departments <- master[master$level == "department", ]
departments <- tibble::as_tibble(departments[, c("inei", "department", common)])

provinces <- master[master$level == "province", ]
provinces <- tibble::as_tibble(provinces[, c("inei", "department", "province", common)])

districts <- master[master$level == "district", ]
districts$district <- districts$name
districts <- tibble::as_tibble(districts[, c("inei", "department", "province", "district", common)])

usethis::use_data(departments, provinces, districts,
                  inei1999_districts,
                  division_counts, inei_provinces_created,
                  inei_districts_created, inei_district_origins,
                  districts_created_2020_2025,
                  overwrite = TRUE, compress = "xz", version = 3)

# CSV copies for non-R users
dir.create("inst/extdata", showWarnings = FALSE, recursive = TRUE)
for (nm in c("departments", "provinces", "districts", "inei1999_districts",
             "division_counts", "inei_provinces_created",
             "inei_districts_created", "inei_district_origins",
             "districts_created_2020_2025")) {
  utils::write.csv(get(nm), file.path("inst", "extdata", paste0(nm, ".csv")),
                   row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
