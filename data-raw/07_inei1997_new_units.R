# Step 7: provinces and districts created 1990-1997 (INEI 1997)
#
# Source: Instituto Nacional de Estadística e Informática (1997). Compendio
#   Estadístico 1996-97. Lima: INEI.
#   Cuadro 1.18, "Perú: Categoría de la capital legal y ley de creación de
#     nuevas provincias, según región y departamento, 1990 - 97".
#   Cuadro 1.19, "Perú: Categoría de la capital legal y ley de creación de
#     nuevos distritos, según región y provincia, 1990 - 97".
#   https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/LIB0170/n00.htm
#
# Both tables give, for each unit created between 1990 and mid-1997, the
# number and DATE of the law of creation (INEI 2020/2022 give only the year
# for districts and the publication date for provinces), the legal capital and
# its category (ciudad, villa, pueblo), and the 1997 region.
#
# Input : data-raw/inei_lib0170/iecaa018.txt, iecaa019.txt (text copied from the pages)
# Output: `inei1997_provinces`, `inei1997_districts` in the calling environment

months97 <- c(ENE = 1, FEB = 2, MAR = 3, ABR = 4, MAY = 5, JUN = 6, JUL = 7,
              AGO = 8, SET = 9, OCT = 10, NOV = 11, DIC = 12)
date97 <- function(x) {
  p <- do.call(rbind, strsplit(x, "-"))
  as.Date(sprintf("19%s-%02d-%s", p[, 3], months97[p[, 2]], p[, 1]))
}

# Rows have 4 leading spaces, then text fields separated by 2+ spaces, the
# category of the capital, the law number and the date (DD-MMM-YY). Region
# headers start at column 1 and may span two lines. Names that wrap continue on
# the next line, in the same column.
parse_inei1997_new <- function(path, n_text) {
  x <- readLines(path, encoding = "UTF-8", warn = FALSE)
  body <- x[(grep("^À", x)[1] + 1):(grep("^Ä", x)[1] - 1)]
  rx <- paste0("^ {4}(\\S.*?)",
               paste(rep("\\s{2,}(\\S.*?)", n_text - 1), collapse = ""),
               "\\s*(CIUDAD|VILLA|PUEBLO)\\s+(\\d+)\\s+(\\d{2}-[A-Z]{3}-\\d{2})\\s*$")
  rows <- list(); region <- character(0); prev_header <- FALSE; starts <- NULL
  for (l in body) {
    if (!nzchar(trimws(l))) { prev_header <- FALSE; next }
    m <- regmatches(l, regexec(rx, l))[[1]]
    if (length(m)) {
      f <- trimws(m[2:(n_text + 1)])
      # column where each text field starts (searched left to right), used to
      # place the continuation lines of wrapped names
      starts <- integer(n_text); from <- 1L
      for (k in seq_len(n_text)) {
        starts[k] <- from - 1L + regexpr(f[k], substring(l, from), fixed = TRUE)[[1]]
        from <- starts[k] + nchar(f[k])
      }
      rows[[length(rows) + 1]] <- c(region = paste(region, collapse = " "), f,
                                    category = m[n_text + 2], law_number = m[n_text + 3],
                                    date_text = m[n_text + 4])
      prev_header <- FALSE
    } else if (grepl("^\\S", l)) {              # region header (may span 2 lines)
      region <- if (prev_header) c(region, trimws(l)) else trimws(l)
      prev_header <- TRUE
    } else {                                     # continuation of wrapped names
      tok <- gregexpr("\\S+( \\S+)*", l)[[1]]
      txt <- regmatches(l, list(tok))[[1]]
      for (k in seq_along(tok)) {
        col <- max(which(starts <= tok[k]))
        r <- rows[[length(rows)]]
        r[col + 1] <- paste(r[col + 1], txt[k])
        rows[[length(rows)]] <- r
      }
    }
  }
  out <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  out$region <- gsub("\\s+", " ", out$region)
  out$region <- sub("- ", "", sub("^L0RETO$", "LORETO", out$region))  # source typo; hyphenated wrap
  out$date <- date97(out$date_text)
  out
}

# ---- Cuadro 1.18: provinces --------------------------------------------------
p97 <- parse_inei1997_new("data-raw/inei_lib0170/iecaa018.txt", n_text = 3)
names(p97)[2:4] <- c("department", "province", "capital")
p25 <- units2025[units2025$level == "province", ]
p97$inei <- p25$inei[match(paste(substr(dept_code(p97$department), 1, 2), norm_inei2020(p97$province)),
                           paste(substr(p25$inei, 1, 2), norm_inei2020(p25$name)))]
stopifnot(nrow(p97) == 11, !anyNA(p97$inei))

# ---- Cuadro 1.19: districts --------------------------------------------------
d97 <- parse_inei1997_new("data-raw/inei_lib0170/iecaa019.txt", n_text = 4)
names(d97)[2:5] <- c("department", "province", "district", "capital")
d97$inei <- match_district(d97$department, d97$province, d97$district)
stopifnot(nrow(d97) == 34, !anyNA(d97$inei), !anyDuplicated(d97$inei))

# ---- Cross-checks with INEI (2020/2022) ---------------------------------------
# Same units, same years; law numbers compared and differences flagged.
note97 <- function(law97, law20, what) {
  ifelse(law97 == law20, NA_character_,
         sprintf("Law number differs between sources: %s (INEI 1997) and %s (INEI 2020/2022, %s).",
                 law97, law20, what))
}
ip <- match(p97$inei, inei_provinces_created$inei)
stopifnot(!anyNA(ip), all(format(p97$date, "%Y") == format(inei_provinces_created$published[ip], "%Y")))
p97$note <- note97(p97$law_number, inei_provinces_created$law_number[ip], "province table")
# The law date normally precedes the publication date (INEI 2020) by 1-2 days;
# flag the provinces where it does not.
gap <- as.integer(inei_provinces_created$published[ip] - p97$date)
p97$note <- ifelse(gap < 0 | gap > 7,
  paste0(ifelse(is.na(p97$note), "", paste0(p97$note, " ")),
         sprintf("Law date (%s) inconsistent with publication date in INEI 2020 (%s).",
                 format(p97$date), format(inei_provinces_created$published[ip]))),
  p97$note)

id <- match(d97$inei, inei_districts_created$inei)
stopifnot(!anyNA(id), all(as.integer(format(d97$date, "%Y")) == inei_districts_created$year[id]))
d97$note <- note97(d97$law_number, inei_districts_created$law_number[id], "district table")
# All INEI 2020 districts created 1990-1995 should be in Cuadro 1.19
miss <- setdiff(inei_districts_created$inei[inei_districts_created$year %in% 1990:1995], d97$inei)
# (Huayrapata and Tilali, created with the province of Moho by Law 25360 in
# 1991, are not in Cuadro 1.19.)
if (length(miss)) message("INEI 2020 districts created 1990-95 not in INEI 1997 cuadro 1.19: ",
                          paste(miss, collapse = ", "))

inei1997_provinces <- tibble::as_tibble(p97[, c(
  "inei", "region", "department", "province", "capital", "category",
  "law_number", "date_text", "date", "note")])
inei1997_districts <- tibble::as_tibble(d97[, c(
  "inei", "region", "department", "province", "district", "capital", "category",
  "law_number", "date_text", "date", "note")])
message("INEI 1997: ", nrow(inei1997_provinces), " provinces and ",
        nrow(inei1997_districts), " districts created 1990-97 parsed and matched; ",
        sum(!is.na(inei1997_provinces$note)) + sum(!is.na(inei1997_districts$note)),
        " rows flagged in `note`")
