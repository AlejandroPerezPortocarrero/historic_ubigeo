# Helper functions shared by the data-raw scripts

# Upper case, no accents, single spaces; keeps the Ñ
normalize_name <- function(x) {
  x <- toupper(trimws(gsub("\\s+", " ", x)))
  x <- gsub("Ñ", "@@", x)
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  gsub("@@", "Ñ", x)
}

# Fix UTF-8 text that was decoded as CP1252 (e.g. "CAÃ‘ETE" -> "CAÑETE")
fix_mojibake <- function(x) {
  vapply(x, function(s) {
    b <- iconv(s, from = "UTF-8", to = "CP1252", toRaw = TRUE)[[1]]
    if (is.null(b)) return(s)
    r <- rawToChar(b)
    Encoding(r) <- "UTF-8"
    if (validUTF8(r) && r != s) r else s
  }, character(1), USE.NAMES = FALSE)
}

unit_level <- function(ubigeo) {
  ifelse(substr(ubigeo, 3, 6) == "0000", "department",
         ifelse(substr(ubigeo, 5, 6) == "00", "province", "district"))
}

census_years <- c(1981, 1993, 2007, 2017, 2025)
