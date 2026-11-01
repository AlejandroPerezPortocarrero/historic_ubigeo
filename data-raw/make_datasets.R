# Builds every dataset in the package.
# Run from the package root:  source("data-raw/make_datasets.R")

source("data-raw/00_helpers.R")
source("data-raw/01_units_2025.R")
source("data-raw/02_inei1999_creation.R")

# ---- Master table (all levels) -------------------------------------------
master <- units2025
master$created_date     <- NA_character_
master$legal_instrument <- NA_character_
master$independence_era <- NA
master$creation_source  <- NA_character_
master$note             <- NA_character_

idx <- match(master$inei, inei1999_districts$inei)
has <- !is.na(idx)
instr <- trimws(paste(ifelse(is.na(inei1999_districts$instrument_type), "", inei1999_districts$instrument_type),
                      ifelse(is.na(inei1999_districts$instrument_number), "", inei1999_districts$instrument_number)))
instr[instr == ""] <- NA
master$created_date[has]     <- inei1999_districts$created_date[idx[has]]
master$legal_instrument[has] <- instr[idx[has]]
master$independence_era[has] <- inei1999_districts$independence_era[idx[has]]
master$creation_source[has]  <- "INEI 1999"
master$note[has]             <- inei1999_districts$note[idx[has]]
master$created_date <- as.Date(master$created_date)

for (y in census_years) master[[paste0("census_", y)]] <- NA_integer_
master$census_2025 <- 1L

dept_name <- setNames(master$name, master$inei)
master$department <- dept_name[paste0(substr(master$inei, 1, 2), "0000")]
master$province   <- ifelse(master$level == "department", NA,
                            dept_name[paste0(substr(master$inei, 1, 4), "00")])

common <- c("created_date", "legal_instrument", "independence_era",
            "creation_source", "note", paste0("census_", census_years))

departments <- master[master$level == "department", ]
departments <- tibble::as_tibble(departments[, c("inei", "department", common)])

provinces <- master[master$level == "province", ]
provinces <- tibble::as_tibble(provinces[, c("inei", "department", "province", common)])

districts <- master[master$level == "district", ]
districts$district <- districts$name
districts <- tibble::as_tibble(districts[, c("inei", "department", "province", "district", common)])

usethis::use_data(departments, provinces, districts, inei1999_districts,
                  overwrite = TRUE, compress = "xz", version = 3)

# CSV copies for non-R users
dir.create("inst/extdata", showWarnings = FALSE, recursive = TRUE)
for (nm in c("departments", "provinces", "districts", "inei1999_districts")) {
  utils::write.csv(get(nm), file.path("inst", "extdata", paste0(nm, ".csv")),
                   row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
