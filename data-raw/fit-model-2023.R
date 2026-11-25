# fit-model-2023.R -- fit the 2023 anchor model shipped as `gov_model_2023`.
#
# Population: every 501(c)(3) full Form 990 e-filed for tax year 2023
# (deduplicated to one filing per organization), with non-negative total
# expenses. Model: bifactor 2PL (mirt::bfactor) on the 16 GI_* practice items
# from get_features(), with four testlets (specific factors):
#   1 financial assurance: GI_REVIEW_AUDIT, GI_AUDIT, GI_AUDIT_CMTE, GI_ACCRUAL
#   2 minutes:             GI_MINUTES_BOARD, GI_MINUTES_CMTE
#   3 written policies:    GI_COI, GI_COI_DISCLOSE, GI_COI_MONITOR, GI_WHISTLE, GI_RETENTION
#   4 compensation:        GI_COMP_CEO, GI_COMP_OTH
# GI_INDEP_MAJOR, GI_990_BOARD and GI_990_WEB load on the general factor only.
#
# Model selection, invariance tests, and validation are documented in the
# accompanying paper (Lecy & Yoon) and in vignette("making-gov-scores").
#
# Runtime: ~5 min to read the tables (cached after the first run) and ~8 min to
# fit. Set GOV_EFILE_CACHE to reuse a local panel990 cache.

library(panel990)
library(mirt)
pkgload::load_all(".")

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
panel <- panel_deduplicate(panel)
dat <- as.data.frame(panel)

c3  <- toupper(trimws(dat$F9_00_EXEMPT_STAT_501C3_X)) %in% "X"
exp <- suppressWarnings(as.numeric(dat$F9_01_EXP_TOT_CY))
dat <- dat[c3 & !is.na(exp) & exp >= 0, ]
message(nrow(dat), " 501(c)(3) full-990 filers in 2023")

f <- suppressMessages(get_features(dat))
items <- governance:::.gi_items
X <- f[, items]
spec <- c(1, 1, 1, 1, NA, 2, 2, NA, 3, 3, 3, 3, 3, 4, 4, NA)
names(spec) <- items

set.seed(2023)
fit <- bfactor(X, spec, verbose = TRUE, technical = list(NCYCLES = 2000))

gov_model_2023 <- list(
  values   = mod2values(fit),
  spec     = spec,
  items    = items,
  factors  = c("gov_score", "gov_s_finance", "gov_s_minutes", "gov_s_policy", "gov_s_comp"),
  year     = 2023L,
  n        = nrow(X),
  logLik   = extract.mirt(fit, "logLik"),
  BIC      = extract.mirt(fit, "BIC"),
  loadings = summary(fit, verbose = FALSE)$rotF,
  item_means = colMeans(X, na.rm = TRUE),
  mirt_version = as.character(utils::packageVersion("mirt")),
  fitted   = Sys.Date()
)
print(round(gov_model_2023$loadings, 2))
usethis::use_data(gov_model_2023, overwrite = TRUE, compress = "xz")
