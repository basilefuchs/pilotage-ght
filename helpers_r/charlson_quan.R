# charlson_quan — score de Charlson pondéré, version Quan 2005
# Référence : Quan H et al. Med Care 2005;43(11):1130-9 (PMID 16224307)
# Entrée : tbl_diag = tbl() lazy avec colonnes (ident, diag), codes CIM-10
# Sortie : tbl() lazy (ident, charlson) — somme des poids, 0 si aucune comorbidité
#
# Utilisation typique :
#   source("helpers_r/charlson_quan.R")
#   charlson <- compute_charlson_quan(tbl_diag)
#   cohorte <- cohorte %>% left_join(charlson, by = "ident") %>%
#                         mutate(charlson = coalesce(charlson, 0L))
#
# Compatible dbplyr / Teradata : utilise substr() + %in% (pas de regex SQL-side).

compute_charlson_quan <- function(tbl_diag) {

  tbl_diag %>%
    mutate(
      d3 = substr(diag, 1, 3),
      d4 = substr(diag, 1, 4)
    ) %>%
    mutate(
      # --- Poids 1 ---
      mi      = as.integer(d3 %in% c("I21","I22") | d4 == "I252"),
      chf     = as.integer(d3 %in% c("I43","I50") |
                           d4 %in% c("I099","I110","I130","I132","I255","I420",
                                     "I425","I426","I427","I428","I429","P290")),
      pvd     = as.integer(d3 %in% c("I70","I71") |
                           d4 %in% c("I731","I738","I739","I771","I790","I792",
                                     "K551","K558","K559","Z958","Z959")),
      cvd     = as.integer(d3 %in% c("G45","G46") |
                           substr(diag,1,2) == "I6" |
                           d4 == "H340"),
      dementia = as.integer(d3 %in% c("F00","F01","F02","F03","G30") |
                            d4 %in% c("F051","G311")),
      copd    = as.integer(d3 %in% c("J40","J41","J42","J43","J44","J45","J46","J47",
                                     "J60","J61","J62","J63","J64","J65","J66","J67") |
                           d4 %in% c("I278","I279","J684","J701","J703")),
      rheum   = as.integer(d3 %in% c("M05","M06","M32","M33","M34") |
                           d4 %in% c("M315","M351","M353","M360")),
      pud     = as.integer(d3 %in% c("K25","K26","K27","K28")),
      mild_liver = as.integer(d3 %in% c("B18","K73","K74") |
                              d4 %in% c("K700","K701","K702","K703","K709",
                                        "K713","K714","K715","K717",
                                        "K760","K762","K763","K764","K768","K769","Z944")),
      diab_wo = as.integer(d4 %in% c("E100","E101","E106","E108","E109",
                                     "E110","E111","E116","E118","E119",
                                     "E120","E121","E126","E128","E129",
                                     "E130","E131","E136","E138","E139",
                                     "E140","E141","E146","E148","E149")),
      # --- Poids 2 ---
      diab_w  = as.integer(d4 %in% c("E102","E103","E104","E105","E107",
                                     "E112","E113","E114","E115","E117",
                                     "E122","E123","E124","E125","E127",
                                     "E132","E133","E134","E135","E137",
                                     "E142","E143","E144","E145","E147")),
      hemi    = as.integer(d3 %in% c("G81","G82") |
                           d4 %in% c("G041","G114","G801","G802",
                                     "G830","G831","G832","G833","G834","G839")),
      renal   = as.integer(d3 %in% c("N18","N19") |
                           d4 %in% c("I120","I131",
                                     "N032","N033","N034","N035","N036","N037",
                                     "N052","N053","N054","N055","N056","N057",
                                     "N250","Z490","Z491","Z492","Z940","Z992")),
      cancer  = as.integer(substr(diag,1,2) %in% c("C0","C1") |
                           d3 %in% c("C20","C21","C22","C23","C24","C25","C26",
                                     "C30","C31","C32","C33","C34",
                                     "C37","C38","C39","C40","C41",
                                     "C43","C45","C46","C47","C48","C49",
                                     "C50","C51","C52","C53","C54","C55","C56","C57","C58",
                                     "C60","C61","C62","C63","C64","C65","C66","C67","C68","C69",
                                     "C70","C71","C72","C73","C74","C75","C76",
                                     "C81","C82","C83","C84","C85","C88",
                                     "C90","C91","C92","C93","C94","C95","C96","C97")),
      # --- Poids 3 ---
      sev_liver = as.integer(d4 %in% c("I850","I859","I864","I982",
                                       "K704","K711","K721","K729",
                                       "K765","K766","K767")),
      # --- Poids 6 ---
      mets    = as.integer(d3 %in% c("C77","C78","C79","C80")),
      hiv     = as.integer(d3 %in% c("B20","B21","B22","B24"))
    ) %>%
    group_by(ident) %>%
    summarise(
      mi = max(mi, na.rm = TRUE),
      chf = max(chf, na.rm = TRUE),
      pvd = max(pvd, na.rm = TRUE),
      cvd = max(cvd, na.rm = TRUE),
      dementia = max(dementia, na.rm = TRUE),
      copd = max(copd, na.rm = TRUE),
      rheum = max(rheum, na.rm = TRUE),
      pud = max(pud, na.rm = TRUE),
      mild_liver = max(mild_liver, na.rm = TRUE),
      diab_wo = max(diab_wo, na.rm = TRUE),
      diab_w = max(diab_w, na.rm = TRUE),
      hemi = max(hemi, na.rm = TRUE),
      renal = max(renal, na.rm = TRUE),
      cancer = max(cancer, na.rm = TRUE),
      sev_liver = max(sev_liver, na.rm = TRUE),
      mets = max(mets, na.rm = TRUE),
      hiv = max(hiv, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      # Hiérarchies Quan : sévère écrase léger
      mild_liver = if_else(sev_liver == 1L, 0L, mild_liver),
      diab_wo    = if_else(diab_w == 1L,    0L, diab_wo),
      cancer     = if_else(mets == 1L,      0L, cancer),
      charlson = mi + chf + pvd + cvd + dementia + copd + rheum + pud +
                 mild_liver + diab_wo +
                 2L * (diab_w + hemi + renal + cancer) +
                 3L * sev_liver +
                 6L * (mets + hiv)
    ) %>%
    select(ident, charlson)
}
