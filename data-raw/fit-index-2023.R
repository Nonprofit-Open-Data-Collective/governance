# fit-index-2023.R -- fit the 2023 governance index model shipped as `gov_index_2023`.
#
# Population: every 501(c)(3) full Form 990 e-filed for tax year 2023
# (deduplicated to one filing per organization), with non-negative total
# expenses -- the same population as `gov_model_2023` (fit-model-2023.R).
#
# Model: unidimensional graded response model (mirt::mirt, itemtype "graded"
# for ordinal items, "2PL" for binary ones) on ten items built from the 16
# GI_* practices returned by get_features(). Nested practices are summed into
# ordinal items (see governance:::.index_bundles):
#   assurance  GI_REVIEW_AUDIT + GI_AUDIT + GI_AUDIT_CMTE (0-3)
#   coi        GI_COI + GI_COI_DISCLOSE + GI_COI_MONITOR  (0-3)
#   minutes    GI_MINUTES_BOARD + GI_MINUTES_CMTE         (0-2)
#   pay        GI_COMP_CEO + GI_COMP_OTH                  (0-2)
#   accrual, indep, f990, whistle, retention, web990     (0/1)
# A unidimensional model with positive slopes is monotone in every item, so
# adding a practice can never lower the score. The bifactor model in
# gov_model_2023 is not: its EAP general score falls for many organizations
# when, for example, committee minutes are added (Hooker, Finkelman &
# Schwartzman 2009, Psychometrika 74: 419-442).
#
# Scale: the EAP estimates of the 2023 population are set to mean 100 and
# SD 15. The two constants (mu, sd) are stored with the model, so every year
# is scored on the 2023 scale.
#
# Data: by default the 2023 tables are read with panel990, as in
# fit-model-2023.R. To reuse a saved data frame of the same filings (raw 990
# columns), set GOV_RAW_2023 to an .rds file.

library(mirt)
pkgload::load_all(".")

raw_file <- Sys.getenv("GOV_RAW_2023", "")
if (nzchar(raw_file)) {
  dat <- as.data.frame(readRDS(raw_file))
} else {
  library(panel990)
  cache <- Sys.getenv("GOV_EFILE_CACHE", "efdata")
  sfw <- create_sfw(name = "governance 2023 anchor", form_type = "990")
  panel <- panelize(
    sfw = sfw,
    tables = c("F9-P00-T00-HEADER", "F9-P01-T00-SUMMARY", governance:::.gov_tables),
    years = 2023, bmf = FALSE, cache = "retain", path = cache,
    columns = c(governance:::.gov_keys, governance:::.all_gov_fields(),
                "F9_00_EXEMPT_STAT_501C3_X", "F9_01_EXP_TOT_CY"),
    verbose = TRUE
  )
  dat <- as.data.frame(panel_deduplicate(panel))
}
c3  <- toupper(trimws(dat$F9_00_EXEMPT_STAT_501C3_X)) %in% c("X", "1", "TRUE")
exp <- suppressWarnings(as.numeric(dat$F9_01_EXP_TOT_CY))
dat <- dat[c3 & !is.na(exp) & exp >= 0, ]
message(nrow(dat), " 501(c)(3) full-990 filers in 2023")

f <- suppressMessages(get_features(dat))
X <- governance:::.bundle_index_items(f)
itemtype <- ifelse(vapply(X, max, numeric(1), na.rm = TRUE) > 1, "graded", "2PL")

set.seed(2023)
fit <- mirt(X, 1, itemtype = itemtype, verbose = TRUE, technical = list(NCYCLES = 2000))
sc  <- fscores(fit, method = "EAP", full.scores.SE = TRUE)
m2  <- M2(fit, type = "C2")

gov_index_2023 <- list(
  values   = mod2values(fit),
  items    = names(X),
  itemtype = unname(itemtype),
  bundles  = governance:::.index_bundles,
  mu       = mean(sc[, 1]),
  sd       = stats::sd(sc[, 1]),
  year     = 2023L,
  n        = nrow(X),
  fit      = c(RMSEA = m2$RMSEA, SRMSR = m2$SRMSR, CFI = m2$CFI, TLI = m2$TLI,
               reliability = stats::var(sc[, 1]) / (stats::var(sc[, 1]) + mean(sc[, 2]^2))),
  coef     = coef(fit, IRTpars = TRUE, simplify = TRUE)$items,
  mirt_version = as.character(utils::packageVersion("mirt")),
  fitted   = Sys.Date()
)
print(gov_index_2023[c("mu", "sd", "n", "fit")])
usethis::use_data(gov_index_2023, overwrite = TRUE, compress = "xz")
