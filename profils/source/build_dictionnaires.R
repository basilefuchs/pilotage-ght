# ---------------------------------------------------------------------------
# build_dictionnaires.R — génère les dictionnaires greppables de profils/dictionnaires/
#
# Sources (dans profils/source/) :
#   - Kwikly.zip            documentation SNDS Kwikly (HTML, CNAM via HDH)
#   - atih-AAAA-MM-JJ.xlsx  dictionnaire des variables de la base nationale ATIH
#                           (nommage SAS ; le plus récent est utilisé s'il y en a plusieurs)
#
# Sorties (dans profils/dictionnaires/) :
#   - snds.csv          domaine;table;libelle_table;variable;libelle;type;longueur;remarques
#   - portail_atih.csv  champ;schema_teradata;table;colonne;libelle;type;longueur;annees;jointure;commentaire;schema_sas
#
# Les champs texte sont nettoyés (balises retirées, ; → , , sauts de ligne → espace)
# pour garantir un fichier strictement greppable : une ligne = une variable.
#
# Usage : Rscript profils/source/build_dictionnaires.R
# ---------------------------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(readr)
library(tibble)

# --- Chemins (relatifs à l'emplacement du script) --------------------------

args       <- commandArgs(trailingOnly = FALSE)
script     <- sub("^--file=", "", grep("^--file=", args, value = TRUE)[1])
dir_source <- dirname(normalizePath(script))
dir_dico   <- file.path(dirname(dir_source), "dictionnaires")
dir.create(dir_dico, showWarnings = FALSE)

# --- Nettoyage commun des champs texte --------------------------------------

nettoyer <- function(x) {
  x |>
    str_remove_all("<[^>]+>") |>
    str_replace_all("&nbsp;", " ") |>
    str_replace_all("&amp;", "&") |>
    str_replace_all("&lt;", "<") |>
    str_replace_all("&gt;", ">") |>
    str_replace_all("&#39;", "'") |>
    str_replace_all("[\r\n\t]+", " ") |>
    str_replace_all(";", ",") |>
    str_squish() |>
    coalesce("")
}

# ===========================================================================
# 1. SNDS — parsing du HTML Kwikly
# ===========================================================================

zip_kwikly <- file.path(dir_source, "Kwikly.zip")

if (file.exists(zip_kwikly)) {
  tmp <- file.path(tempdir(), "kwikly_extract")
  unlink(tmp, recursive = TRUE)
  unzip(zip_kwikly, exdir = tmp)

  # 1 fichier HTML par table dans chaque sous-dossier de domaine ;
  # les .html à la racine de Kwikly/ sont des menus, ignorés par le pattern */*.html
  fichiers <- list.files(file.path(tmp, "Kwikly"),
                         pattern = "\\.html$", recursive = TRUE, full.names = TRUE)
  fichiers <- fichiers[basename(dirname(fichiers)) != "Kwikly"]

  parse_kwikly_html <- function(chemin) {
    html <- read_file(chemin)

    h1 <- str_match(html, "<h1>(\\w+) - (\\S+)\\s*:\\s*([^<]*)</h1>")
    if (is.na(h1[1, 1])) return(NULL)

    # Lignes de variables : la 1re cellule est <td > ou <td class="data">
    # selon le domaine ; libellé/remarques peuvent contenir du balisage.
    lignes <- str_match_all(
      html,
      regex(paste0(
        "<tr class=\"data\"><td[^>]*>([A-Za-z0-9_]+)</td>",
        "<td class=\"data\">(.*?)</td>",        # libellé
        "<td class=\"data\">(.*?)</td>",        # type
        "<td class=\"data right\">(.*?)</td>",  # longueur
        "<td class=\"data\">(.*?)</td>"         # remarques
      ), dotall = TRUE)
    )[[1]]
    if (nrow(lignes) == 0) return(NULL)

    tibble(
      domaine       = h1[1, 2],
      table         = h1[1, 3],
      libelle_table = nettoyer(h1[1, 4]),
      variable      = lignes[, 2],
      libelle       = nettoyer(lignes[, 3]),
      type          = nettoyer(lignes[, 4]),
      longueur      = nettoyer(lignes[, 5]),
      remarques     = nettoyer(lignes[, 6])
    )
  }

  dico_snds <- map_dfr(fichiers, parse_kwikly_html) |>
    # Les tables de valeurs sont dupliquées entre AUTRE et VALEUR :
    # on rattache chaque table à son domaine le plus spécifique
    group_by(table) |>
    mutate(
      domaine       = if (any(domaine != "AUTRE")) domaine[domaine != "AUTRE"][1] else "AUTRE",
      libelle_table = if (any(libelle_table != "")) libelle_table[libelle_table != ""][1] else ""
    ) |>
    ungroup() |>
    distinct(table, variable, .keep_all = TRUE) |>
    arrange(domaine, table, variable)

  write_delim(dico_snds, file.path(dir_dico, "snds.csv"), delim = ";")

  cat("snds.csv :", n_distinct(dico_snds$table), "tables,",
      nrow(dico_snds), "variables\n")
  dico_snds |> count(domaine) |> as.data.frame() |> print(row.names = FALSE)
} else {
  cat("Kwikly.zip absent de profils/source/ — snds.csv non régénéré\n")
}

# ===========================================================================
# 2. Portail ATIH — dictionnaire Excel (nommage SAS → Teradata)
# ===========================================================================

xlsx_atih <- sort(list.files(dir_source, pattern = "^atih.*\\.xlsx$", full.names = TRUE))

if (length(xlsx_atih) > 0) {
  xlsx_atih <- tail(xlsx_atih, 1)  # le plus récent (tri lexical sur la date du nom)
  cat("\nSource ATIH :", basename(xlsx_atih), "\n")

  brut <- readxl::read_excel(xlsx_atih, col_types = "text") |>
    # certaines cellules contiennent la chaîne littérale "NA"
    mutate(across(everything(), \(x) na_if(x, "NA")))

  # Règle de nommage SAS → Teradata :
  #   <champ>xxbd  → prd_vue_<champ>_AAAA   (ssr renommé smr côté Teradata)
  #   rpuxx        → prd_vue_rpu_AAAA       (à confirmer à l'usage)
  #   nomenclatures (nom_gen, nom_pmsi, nom_urg, agg_pmsi) : nom SAS conservé,
  #   utilisé tel quel dans les scripts existants (cf. nom_gen.finess_codegeo_distance_tps)
  dico_atih <- brut |>
    mutate(
      champ = case_when(
        librairie == "ssrxxbd"                  ~ "smr",
        str_detect(librairie, "^\\w+xxbd$")     ~ str_remove(librairie, "xxbd$"),
        librairie == "rpuxx"                    ~ "rpu",
        TRUE                                    ~ "ref"
      ),
      schema_teradata = case_when(
        librairie == "ssrxxbd"              ~ "prd_vue_smr_AAAA",
        str_detect(librairie, "^\\w+xxbd$") ~ str_replace(librairie, "^(\\w+)xxbd$", "prd_vue_\\1_AAAA"),
        librairie == "rpuxx"                ~ "prd_vue_rpu_AAAA",
        TRUE                                ~ librairie
      ),
      annees = if_else(!is.na(andeb) & !is.na(anfin),
                       paste0("20", andeb, "-20", anfin), "")
    ) |>
    transmute(
      champ,
      schema_teradata,
      table       = nettoyer(table),
      colonne     = nettoyer(var),
      libelle     = nettoyer(libelle),
      type        = nettoyer(type),
      longueur    = nettoyer(longueur),
      annees,
      jointure    = nettoyer(jointure),
      commentaire = nettoyer(commentaire),
      schema_sas  = librairie
    ) |>
    arrange(champ, schema_teradata, table, colonne)

  write_delim(dico_atih, file.path(dir_dico, "portail_atih.csv"), delim = ";")

  cat("portail_atih.csv :", n_distinct(paste(dico_atih$schema_sas, dico_atih$table)),
      "tables,", nrow(dico_atih), "variables\n")
  dico_atih |> count(champ, schema_teradata) |> as.data.frame() |> print(row.names = FALSE)
} else {
  cat("\nAucun fichier atih*.xlsx dans profils/source/ — portail_atih.csv non régénéré\n")
}
