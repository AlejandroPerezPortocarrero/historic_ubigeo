# Step 2: creation date and legal instrument of districts (INEI 1999)
#
# Source: INEI (1999). Perú: Directorio Nacional de Municipalidades Provinciales
#   y Distritales 1999. Table X.3 "Dispositivo legal de creación, población total,
#   superficie, densidad poblacional y población electoral de los distritos: 1999".
#   https://proyectos.inei.gob.pe/web/biblioineipub/bancopub/Est/Lib0362/indice.htm
#
# Input : data-raw/inei_lib0362/dis-<code>.txt (text copied from dis-<code>.htm)
# Output: `inei1999_districts` in the calling environment

dept_files <- c(
  amaz = "01", anca = "02", apur = "03", areq = "04", ayac = "05",
  caja = "06", call = "07", cusc = "08", huav = "09", huan = "10",
  ica  = "11", juni = "12", libe = "13", lamb = "14", lima = "15",
  lore = "16", madr = "17", moqu = "18", pasc = "19", piur = "20",
  puno = "21", smar = "22", tacn = "23", tumb = "24", ucay = "25"
)

months <- c(ENE = 1, FEB = 2, MAR = 3, ABR = 4, MAY = 5, JUN = 6, JUL = 7,
            AGO = 8, SET = 9, SEP = 9, OCT = 10, NOV = 11, DIC = 12)

# District names that differ between 1999 and 2025: "dept|province|name1999" = name2025
name_equivalences <- c(
  "15|LIMA|MAGDALENA VIEJA" = "PUEBLO LIBRE",
  "15|HUAROCHIRI|LARAOS"    = "SAN PEDRO DE LARAOS",
  "15|YAUYOS|AYAUCA"        = "ALLAUCA"
)

# Values in the source that look wrong; kept as published but flagged
source_notes <- c(
  "15|HUARAL|VEINTISIETE DE NOVIEMBRE" =
    "Law number (17702) inconsistent with date (1957); possibly Law 12702."
)

parse_date_es <- function(x) {
  m <- regmatches(x, regexec("^(\\d{1,2}) ([A-Z]{3}) (\\d{4})$", trimws(x)))
  vapply(m, function(p) {
    if (length(p) == 0) return(NA_character_)
    sprintf("%s-%02d-%02d", p[4], months[[p[3]]], as.integer(p[2]))
  }, character(1))
}

to_num <- function(x) {
  x <- trimws(x)
  suppressWarnings(as.numeric(ifelse(x %in% c("", "-"), NA, gsub(",", ".", x))))
}

parse_inei1999 <- function(path, dept) {
  lines <- fix_mojibake(readLines(path, encoding = "UTF-8", warn = FALSE))
  i <- grep("^TOTAL\t", lines)[1] + 5
  rows <- list()
  province <- NA_character_
  while (i <= length(lines)) {
    l <- lines[i]
    if (!nzchar(trimws(l))) { i <- i + 1; next }
    if (grepl("^(A/|\\d/|FUENTE)", trimws(l))) break
    ntab <- lengths(regmatches(l, gregexpr("\t", l)))
    if (ntab >= 3) {                       # province row: name + 4 figures
      province <- trimws(strsplit(l, "\t")[[1]][1])
      i <- i + 5
      next
    }
    f <- trimws(lines[(i + 1):(i + 7)])    # district row: name + 7 fields
    rows[[length(rows) + 1]] <- data.frame(
      dept = dept,
      province_1999 = province,
      district_1999 = trimws(strsplit(l, "\t")[[1]][1]),
      instrument_type = ifelse(f[1] == "-", NA, f[1]),
      instrument_number = ifelse(f[2] == "-", NA, f[2]),
      date_text = f[3],
      created_date = parse_date_es(f[3]),
      independence_era = grepl("^EPOCA INDEP", f[3]),
      pop_1998 = to_num(f[4]),
      surface = to_num(f[5]),
      pop_density_1998 = to_num(f[6]),
      electoral_pop_1999 = to_num(f[7])
    )
    i <- i + 8
  }
  do.call(rbind, rows)
}

files <- file.path("data-raw", "inei_lib0362", paste0("dis-", names(dept_files), ".txt"))
present <- file.exists(files)
inei1999_districts <- do.call(rbind, Map(parse_inei1999, files[present], dept_files[present]))
rownames(inei1999_districts) <- NULL

# Match to 2025 ubigeo by department + province name + district name
prov25 <- units2025[units2025$level == "province", ]
prov25$key <- paste(substr(prov25$inei, 1, 2), normalize_name(prov25$name), sep = "|")
dist25 <- units2025[units2025$level == "district", ]
dist25$key <- paste(dist25$parent, normalize_name(dist25$name), sep = "|")

key1999 <- with(inei1999_districts,
                paste(dept, normalize_name(province_1999), normalize_name(district_1999), sep = "|"))
name2025 <- ifelse(key1999 %in% names(name_equivalences),
                   name_equivalences[key1999], normalize_name(inei1999_districts$district_1999))
prov_inei <- prov25$inei[match(
  paste(inei1999_districts$dept, normalize_name(inei1999_districts$province_1999), sep = "|"),
  prov25$key)]
inei1999_districts$inei <- dist25$inei[match(paste(prov_inei, name2025, sep = "|"), dist25$key)]
inei1999_districts$note <- unname(source_notes[key1999])

inei1999_districts <- inei1999_districts[, c(
  "inei", "dept", "province_1999", "district_1999", "instrument_type",
  "instrument_number", "date_text", "created_date", "independence_era",
  "pop_1998", "surface", "pop_density_1998", "electoral_pop_1999", "note")]
inei1999_districts <- tibble::as_tibble(inei1999_districts)

unmatched <- inei1999_districts[is.na(inei1999_districts$inei), c("province_1999", "district_1999")]
if (nrow(unmatched)) {
  print(unmatched, n = Inf)
  stop("Unmatched districts in INEI 1999 tables: add them to `name_equivalences`.")
}
stopifnot(!anyDuplicated(inei1999_districts$inei))
message("INEI 1999 districts parsed and matched: ", nrow(inei1999_districts))
