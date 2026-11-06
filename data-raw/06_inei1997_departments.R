# Step 6: creation of departments (INEI 1997)
#
# Source: Instituto Nacional de Estadística e Informática (1997). Compendio
#   Estadístico 1996-97. Lima: INEI. Cuadro 1.16, "Perú: Superficie, población,
#   densidad poblacional y dispositivo de creación, según departamento, 1997".
#   https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/LIB0170/N02/iecaa016.htm
#
# Input : data-raw/inei_lib0170/iecaa016.txt (text copied from the page)
# Output: `inei1997_departments` in the calling environment

lines97 <- readLines("data-raw/inei_lib0170/iecaa016.txt", encoding = "UTF-8", warn = FALSE)

# The page is DOS text (CP437) read as CP1252 ("Jos‚" -> "José"). In the copy,
# the "á" of "Huánuco" (CP437 0xA0) became a plain space and is restored by hand.
fix_cp437 <- function(x) {
  vapply(x, function(s) {
    b <- iconv(s, from = "UTF-8", to = "CP1252", toRaw = TRUE)[[1]]
    if (is.null(b)) return(s)
    r <- iconv(rawToChar(b), from = "CP437", to = "UTF-8")
    if (is.na(r)) s else r
  }, character(1), USE.NAMES = FALSE)
}
lines97 <- gsub("Hu nuco", "Huánuco", fix_cp437(lines97))

m <- regmatches(lines97, regexec(paste0(
  "^([A-Z][A-Z ]*?)\\s*(\\d/)?\\s+([0-9]+,[0-9]+)\\s+([0-9]+)\\s+([0-9]+,[0-9]+)\\s+",
  "(.+?)\\s{2,}(S/N|-|[0-9]+)\\s+(\\d{2}) ([A-Z]{3}) (\\d{4})\\s*$"), lines97))
m <- do.call(rbind, m[lengths(m) > 0])
stopifnot(nrow(m) == 25)

months97 <- c(ENE = 1, FEB = 2, MAR = 3, ABR = 4, MAY = 5, JUN = 6, JUL = 7,
              AGO = 8, SET = 9, OCT = 10, NOV = 11, DIC = 12)
to_num97 <- function(x) as.numeric(gsub(",", ".", x))

# Footnotes, as published (Spanish), keyed by their marker
fn_start <- grep("^\\s*\\d/ ", lines97)
fn_end <- c(fn_start[-1] - 1, grep("^FUENTE", lines97) - 1)
footnotes <- vapply(seq_along(fn_start), function(k)
  gsub("\\s+", " ", trimws(paste(lines97[fn_start[k]:fn_end[k]], collapse = " "))), "")
names(footnotes) <- sub("^(\\d/).*", "\\1", footnotes)
footnotes <- sub("^\\d/ ", "", footnotes)

inei1997_departments <- data.frame(
  department_1997 = trimws(m[, 2]),
  instrument_type = trimws(m[, 7]),
  instrument_number = m[, 8],
  date_text = paste(m[, 9], m[, 10], m[, 11]),
  created_date = as.Date(sprintf("%s-%02d-%s", m[, 11], months97[m[, 10]], m[, 9])),
  surface = to_num97(m[, 4]),
  pop_1997 = as.numeric(m[, 5]),
  pop_density_1997 = to_num97(m[, 6]),
  footnote = unname(ifelse(m[, 3] == "", NA, footnotes[m[, 3]]))
)
inei1997_departments$instrument_number[inei1997_departments$instrument_number == "-"] <- NA

d25 <- units2025[units2025$level == "department", ]
inei1997_departments$inei <- d25$inei[match(normalize_name(inei1997_departments$department_1997),
                                            normalize_name(sub("^PROV\\. CONST\\. DEL ", "", d25$name)))]
stopifnot(!anyNA(inei1997_departments$inei), !anyDuplicated(inei1997_departments$inei))

inei1997_departments <- tibble::as_tibble(inei1997_departments[, c(
  "inei", "department_1997", "instrument_type", "instrument_number", "date_text",
  "created_date", "surface", "pop_1997", "pop_density_1997", "footnote")])
message("INEI 1997: ", nrow(inei1997_departments), " departments parsed and matched")
