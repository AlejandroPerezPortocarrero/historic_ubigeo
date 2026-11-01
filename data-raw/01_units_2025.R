# Step 1: territorial units in the 2025 Census (reference frame)
#
# Input : data-raw/ubigeo_censo2025.xlsx (INEI list of ubigeos, Census 2025)
# Output: `units2025` (long table, all three levels) in the calling environment

units2025 <- readxl::read_excel("data-raw/ubigeo_censo2025.xlsx",
                                col_types = "text", .name_repair = "minimal")
names(units2025) <- c("inei", "name")
units2025 <- units2025[!is.na(units2025$inei) & grepl("^\\d{6}$", trimws(units2025$inei)), ]
units2025$inei <- trimws(units2025$inei)
units2025$name <- trimws(units2025$name)
units2025$level <- unit_level(units2025$inei)
units2025$parent <- ifelse(
  units2025$level == "department", NA_character_,
  ifelse(units2025$level == "province",
         paste0(substr(units2025$inei, 1, 2), "0000"),
         paste0(substr(units2025$inei, 1, 4), "00"))
)

# Consistency checks
stopifnot(
  !anyDuplicated(units2025$inei),
  all(units2025$parent[!is.na(units2025$parent)] %in% units2025$inei),
  all(units2025$inei[units2025$level == "province"] %in% units2025$parent)
)

message("Units in 2025: ",
        paste(names(table(units2025$level)), table(units2025$level), collapse = ", "))
