# Step 8: legal instruments of creation and modification (PCM-SDOT, GEOSDOT)
#
# Source: Presidencia del Consejo de Ministros, Secretaría de Demarcación y
#   Organización Territorial (PCM-SDOT). Sistema de consultas de información de
#   naturaleza demarcatoria (GEOSDOT), módulo "Circunscripciones".
#   https://geosdot.servicios.gob.pe/consultas/#/circunscripcion
#   (public consultation account; data downloaded on 08/11/2026)
#
# For every department, province and district in the registry, GEOSDOT lists
# the legal instruments that concern it, each tagged as "Creación",
# "Modificación" or "Cancelación", with type, number, date and summary
# (sumilla). The file was built from the same API the web page uses
# (circunscripcionBusquedaPaso1s for the list of units, circunscripcionBusquedaPaso2s
# for the instruments of each unit); one row per unit and instrument.
#
# Input : data-raw/geosdot/geosdot_normas.tsv
# Output: `geosdot_norms` in the calling environment

g <- utils::read.delim("data-raw/geosdot/geosdot_normas.tsv", colClasses = "character",
                       encoding = "UTF-8", quote = "", na.strings = "")
stopifnot(nrow(g) == 4788, length(unique(g$id_circunscripcion)) == 2091)

# GEOSDOT codes Lima Metropolitana as province 2601 (INEI: 1501)
g$id_provincia[g$id_provincia %in% "2601"] <- "1501"

# District names that differ from the 2025 frame ("province code|GEOSDOT name" = 2025 name)
geosdot_equivalences <- c(
  "1002|TOMAYQUICHUA" = "TOMAY KICHWA",
  "1401|PUERTO ETEN"  = "ETEN PUERTO",
  "2105|CAPASO"       = "CAPAZO",
  "2502|RAYMONDI"     = "RAIMONDI"
)

u25 <- units2025
u25$nn <- normalize_name(sub("^PROV\\. CONST\\. DEL ", "", u25$name))
dkey <- paste(substr(u25$inei, 1, 4), u25$nn)[u25$level == "district"]
dinei <- u25$inei[u25$level == "district"]

nn <- normalize_name(g$nombre)
k <- paste(g$id_provincia, nn, sep = "|")
nn <- ifelse(k %in% names(geosdot_equivalences), geosdot_equivalences[k], nn)
g$inei <- ifelse(
  g$tipo == "DEPARTAMENTO",
  u25$inei[u25$level == "department"][match(nn, u25$nn[u25$level == "department"])],
  ifelse(g$tipo == "PROVINCIA", paste0(g$id_provincia, "00"),
         dinei[match(paste(g$id_provincia, nn), dkey)]))
g$inei[g$tipo == "PROVINCIA" & !g$inei %in% u25$inei] <- NA

unmatched <- unique(g[is.na(g$inei), c("tipo", "provincia", "nombre")])
if (nrow(unmatched)) { print(unmatched); stop("GEOSDOT units not matched to the 2025 frame") }
# Same unit name in the province: check that province names agree too
p_ok <- g$tipo != "PROVINCIA" |
  normalize_name(g$nombre) == normalize_name(u25$name[match(g$inei, u25$inei)])
stopifnot(all(p_ok | g$id_provincia == "1501"))
stopifnot(!anyDuplicated(unique(g[, c("id_circunscripcion", "inei")])$inei))

months_iso <- function(x) as.Date(ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", x), x, NA))
geosdot_norms <- data.frame(
  inei = g$inei,
  level = c(DEPARTAMENTO = "department", PROVINCIA = "province", DISTRITO = "district")[g$tipo],
  id_geosdot = g$id_circunscripcion,
  name = g$nombre,
  action = g$tipo_accion,
  instrument_type = g$tipo_documento,
  instrument_number = g$numero,
  date = months_iso(g$fecha),
  id_instrument = g$id_dispositivo,
  name_in_instrument = g$nombre_en_norma,
  capital_in_instrument = g$capital_en_norma,
  summary = g$sumilla,
  stringsAsFactors = FALSE
)
geosdot_norms <- geosdot_norms[order(geosdot_norms$inei, geosdot_norms$date), ]
geosdot_norms <- tibble::as_tibble(geosdot_norms)

# One instrument of creation per unit; where GEOSDOT lists two, keep the
# earliest and note the other.
cre <- geosdot_norms[geosdot_norms$action == "Creación", ]
geosdot_creation <- cre[!duplicated(cre$inei), ]
dup <- cre$inei[duplicated(cre$inei)]
# Some districts have a census ("Censo 1876", "Censo 1940", "Censo 1981") as
# their instrument of creation: they are first recorded in that census, with
# no law. They have no date; the year of the census is kept.
is_census <- geosdot_creation$instrument_type == "Censo"
geosdot_creation$year <- as.integer(format(geosdot_creation$date, "%Y"))
geosdot_creation$year[is_census] <- as.integer(
  sub("^\\D*(\\d{4}).*$", "\\1", geosdot_creation$instrument_number[is_census]))
geosdot_creation$instrument <- ifelse(is_census, paste("CENSO", geosdot_creation$year),
  trimws(paste(toupper(geosdot_creation$instrument_type), geosdot_creation$instrument_number)))
stopifnot(!anyNA(geosdot_creation$year))
geosdot_creation$note <- ifelse(
  geosdot_creation$inei %in% dup,
  vapply(geosdot_creation$inei, function(i) {
    o <- cre[cre$inei == i, ][-1, ]
    paste0("GEOSDOT also lists ", o$instrument_type, " ", o$instrument_number, " (",
           format(o$date), ") as an instrument of creation.", collapse = " ")
  }, ""), NA_character_)

message("GEOSDOT: ", nrow(geosdot_norms), " instruments for ",
        length(unique(geosdot_norms$inei)), " units (",
        paste(names(table(geosdot_creation$level)), table(geosdot_creation$level), collapse = ", "),
        "); ", length(dup), " unit(s) with two instruments of creation")
